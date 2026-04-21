import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Blocăm ecranul în mod Landscape pentru o experiență de joc mai bună
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
  late final WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    // AICI E MAGIA: Conexiunea cu serverul tău real din cloud! 🚀
    channel = WebSocketChannel.connect(
      Uri.parse('wss://pong-6tqc.onrender.com/ws'),
    );
  }

  Map? state;

  void sendMove(double y) {
    channel.sink.add(y.toString());
  }

  void resetGame() {
    channel.sink.add("RESET");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Eroare de conexiune la Render.\nVerifică dacă serverul este 'Live'!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 20),
                  Text("Se trezește serverul de pe Render...", style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }

          state = json.decode(snapshot.data.toString());

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
                            Text("${state!['scoreAI']}", style: const TextStyle(color: Colors.blue, fontSize: 60, fontWeight: FontWeight.bold)),
                            Text("${state!['scorePlayer']}", style: const TextStyle(color: Colors.red, fontSize: 60, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Mingea
                      Positioned(
                          left: state!['ballX'].toDouble(),
                          top: state!['ballY'].toDouble(),
                          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                      ),

                      // Paleta Jucător (Roșie)
                      Positioned(right: 20, top: state!['p1Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.red)),

                      // Paleta AI (Albastră)
                      Positioned(left: 20, top: state!['p2Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.blue)),

                      // Mesaj Final (Game Over)
                      if (state!['message'] != "")
                        Container(
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state!['message'], style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
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
    channel.sink.close();
    super.dispose();
  }
}