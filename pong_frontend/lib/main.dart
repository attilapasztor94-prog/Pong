import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Blocăm ecranul în mod Landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MaterialApp(home: PongPro(), debugShowCheckedModeBanner: false));
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

  // Funcție pentru a iniția conexiunea
  void _connectToRender() {
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://pong-6tqc.onrender.com/ws'), // Adresa ta de Render
      );
    });
  }

  void sendMove(double y) {
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
          // CAZ 1: Eroare de conexiune (Serverul e oprit sau se trezește greu)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Serverul de pe Render încă se trezește...\n(Poate dura până la 1 minut)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _connectToRender, // Reîncearcă conexiunea
                    child: const Text("REÎNCEARCĂ CONEXIUNEA"),
                  )
                ],
              ),
            );
          }

          // CAZ 2: Se așteaptă datele (Se stabilește legătura)
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

          // CAZ 3: Conexiune reușită - Jocul pornește
          final state = json.decode(snapshot.data.toString());

          return Center(
            child: Container(
              width: 800,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white12, width: 2),
              ),
              child: MouseRegion(
                onHover: (event) => sendMove(event.localPosition.dy),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => sendMove(details.localPosition.dy),
                  child: Stack(
                    children: [
                      // Linia de mijloc
                      Center(child: Container(width: 2, color: Colors.white24)),

                      // Scor
                      Positioned(
                        top: 20, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${state['scoreAI']}", style: const TextStyle(color: Colors.blue, fontSize: 60, fontWeight: FontWeight.bold)),
                            Text("${state['scorePlayer']}", style: const TextStyle(color: Colors.red, fontSize: 60, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Mingea
                      Positioned(
                          left: state['ballX'].toDouble(),
                          top: state['ballY'].toDouble(),
                          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                      ),

                      // Paleta Jucător (Roșie)
                      Positioned(right: 20, top: state['p1Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.red)),

                      // Paleta AI (Albastră)
                      Positioned(left: 20, top: state['p2Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.blue)),

                      // Mesaj Game Over
                      if (state['message'] != "")
                        Container(
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state['message'], style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                                  onPressed: resetGame,
                                  child: const Text("RESTART", style: TextStyle(fontSize: 20, color: Colors.white)),
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