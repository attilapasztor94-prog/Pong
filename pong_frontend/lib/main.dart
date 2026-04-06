import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MaterialApp(home: PongPro(), debugShowCheckedModeBanner: false));
  });
}

class PongPro extends StatefulWidget {
  const PongPro({super.key}); // Aici adăugăm cheia cerută (Info 1)

  @override
  State<PongPro> createState() => _PongProState(); // Aici ascundem tipul privat _PongProState sub tipul public State<PongPro> (Info 2)
}

class _PongProState extends State<PongPro> {
  // Conexiunea către serverul tău Java local
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/ws'),
  );

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
          if (snapshot.hasError) return Center(child: Text("Eroare de conexiune. Este pornit serverul Java?", style: TextStyle(color: Colors.red, fontSize: 20)));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.red));

          state = json.decode(snapshot.data.toString());

          return Center(
            child: Container(
              width: 800,
              height: 400,
              color: Colors.black,
              child: MouseRegion(
                onHover: (event) => sendMove(event.localPosition.dy),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => sendMove(details.localPosition.dy),
                  child: Stack(
                    children: [
                      Center(child: Container(width: 2, color: Colors.white24)),
                      Positioned(
                        top: 20, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${state!['scoreAI']}", style: TextStyle(color: Colors.blue, fontSize: 60, fontWeight: FontWeight.bold)),
                            Text("${state!['scorePlayer']}", style: TextStyle(color: Colors.red, fontSize: 60, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Positioned(left: state!['ballX'].toDouble(), top: state!['ballY'].toDouble(), child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
                      Positioned(right: 20, top: state!['p1Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.red)),
                      Positioned(left: 20, top: state!['p2Y'].toDouble(), child: Container(width: 15, height: 100, color: Colors.blue)),
                      if (state!['message'] != "")
                        Container(
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state!['message'], style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                                SizedBox(height: 30),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                                  onPressed: resetGame,
                                  child: Text("RESTART", style: TextStyle(fontSize: 20)),
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