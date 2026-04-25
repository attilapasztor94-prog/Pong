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

  // LOGICA PENTRU NUME
  bool isNameEntered = false;
  final TextEditingController _nameController = TextEditingController();

  // NU mai apelăm _connectToRender în initState!
  // O vom apela doar după ce utilizatorul apasă butonul START.
  @override
  void initState() {
    super.initState();
  }

  void _connectToRender() {
    _channel?.sink.close();
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://pong-6tqc.onrender.com/ws'),
      );
    });

    // Trimitem numele la server imediat ce conexiunea s-a stabilit
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_nameController.text.isNotEmpty) {
        _channel?.sink.add("NAME:${_nameController.text}");
      }
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
      // AICI SE FACE MAGIA: Dacă nu a introdus numele, arătăm ecranul de nume
      body: !isNameEntered ? _buildNameInputScreen() : _buildGameScreen(),
    );
  }

  // ECRANUL DE START (INTRODUCERE NUME)
  Widget _buildNameInputScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "PONG MULTIPLAYER",
            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                labelText: "Introdu numele tău",
                labelStyle: const TextStyle(color: Colors.blueAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                setState(() {
                  isNameEntered = true; // Schimbăm starea pentru a afișa jocul
                });
                _connectToRender(); // Pornim conexiunea
              }
            },
            child: const Text("START JOC", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ECRANUL DE JOC (STREAM BUILDER-UL TĂU)
  Widget _buildGameScreen() {
    return StreamBuilder(
      stream: _channel?.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.redAccent, size: 60),
                const Text("Eroare de conexiune!", style: TextStyle(color: Colors.white)),
                ElevatedButton(onPressed: _connectToRender, child: const Text("RECONECTARE"))
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        final state = json.decode(snapshot.data.toString());

        return Center(
          child: FittedBox(
            child: Container(
              width: 800,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24, width: 4),
              ),
              child: MouseRegion(
                onHover: (event) => sendMove(event.localPosition.dy),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => sendMove(details.localPosition.dy),
                  child: Stack(
                    children: [
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
                          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                      ),

                      // Paletele
                      Positioned(right: 20, top: state['p1Y'].toDouble(), child: _paddle(Colors.red)),
                      Positioned(left: 20, top: state['p2Y'].toDouble(), child: _paddle(Colors.blue)),

                      // Mesaj Final
                      if (state['message'] != null && state['message'] != "")
                        _buildGameOverScreen(state['message']),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _paddle(Color color) => Container(width: 15, height: 100, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));

  Widget _buildGameOverScreen(String message) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: resetGame,
              child: const Text("RESTART JOC", style: TextStyle(fontSize: 20, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channel?.sink.close();
    super.dispose();
  }
}
//flutter run -d chrome