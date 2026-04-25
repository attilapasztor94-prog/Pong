import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Blocăm ecranul în mod Landscape (util pentru mobil, ignorat pe Desktop browser)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MaterialApp(
      home: PongPro(),
      debugShowCheckedModeBanner: false,
    ));
  });
}

class PongPro extends StatefulWidget {
  const PongPro({super.key});

  @override
  State<PongPro> createState() => _PongProState();
}

class _PongProState extends State<PongPro> {
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectToRender();
  }

  void _connectToRender() {
    // Închidem conexiunea veche dacă există înainte de a reîncerca
    _channel?.sink.close();
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://pong-6tqc.onrender.com/ws'),
      );
    });
  }

  void sendMove(double y) {
    // Trimitem coordonata Y către server
    _channel?.sink.add(y.toString());
  }

  void resetGame() {
    _channel?.sink.add("RESET");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: StreamBuilder(
        stream: _channel?.stream,
        builder: (context, snapshot) {
          // CAZ 1: Eroare sau Server Offline
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 20),
                  const Text(
                    "Conexiune pierdută sau serverul doarme...\n(Render poate dura 50s să pornească)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _connectToRender,
                    child: const Text("RECONECTARE", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          // CAZ 2: Se așteaptă date (Loading)
          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 20),
                  Text("Se stabilește conexiunea cu Render...",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }

          // CAZ 3: Conexiune activă - Decodare Date
          dynamic state;
          try {
            state = json.decode(snapshot.data.toString());
          } catch (e) {
            return const Center(child: Text("Eroare la procesarea datelor jocului"));
          }

          return Center(
            child: FittedBox( // Se asigură că jocul încape pe orice ecran
              child: Container(
                width: 800,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white24, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 20)
                  ],
                ),
                child: MouseRegion(
                  onHover: (event) => sendMove(event.localPosition.dy),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) => sendMove(details.localPosition.dy),
                    child: Stack(
                      children: [
                        // Linia de mijloc (design retro)
                        Center(child: Container(width: 4, color: Colors.white10)),

                        // Scor AI
                        Positioned(
                          top: 20, left: 150,
                          child: Text("${state['scoreAI']}",
                              style: TextStyle(color: Colors.blue.withOpacity(0.5), fontSize: 80, fontWeight: FontWeight.bold)),
                        ),

                        // Scor Player
                        Positioned(
                          top: 20, right: 150,
                          child: Text("${state['scorePlayer']}",
                              style: TextStyle(color: Colors.red.withOpacity(0.5), fontSize: 80, fontWeight: FontWeight.bold)),
                        ),

                        // Mingea
                        Positioned(
                            left: state['ballX'].toDouble(),
                            top: state['ballY'].toDouble(),
                            child: Container(
                                width: 20, height: 20,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)])
                            )
                        ),

                        // Paleta Player (Roșie - Dreapta)
                        Positioned(
                            right: 20,
                            top: state['p1Y'].toDouble(),
                            child: Container(width: 15, height: 100, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)))
                        ),

                        // Paleta AI (Albastră - Stânga)
                        Positioned(
                            left: 20,
                            top: state['p2Y'].toDouble(),
                            child: Container(width: 15, height: 100, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)))
                        ),

                        // Mesaj Game Over / Start
                        if (state['message'] != null && state['message'] != "")
                          Container(
                            color: Colors.black87,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(state['message'],
                                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                                    ),
                                    onPressed: resetGame,
                                    child: const Text("RESTART JOC", style: TextStyle(fontSize: 20, color: Colors.white)),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
//flutter run -d chrome