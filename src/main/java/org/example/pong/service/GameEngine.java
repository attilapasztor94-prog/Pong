package org.example.pong.service;

import org.example.pong.model.GameState;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import java.io.IOException;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class GameEngine {
    private final CopyOnWriteArrayList<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
    private GameState state = new GameState();

    public void addSession(WebSocketSession session) {
        sessions.add(session);
    }

    public void removeSession(WebSocketSession session) {
        sessions.remove(session);
    }

    // Aceasta este "Inima". Rulează singură la fiecare 20ms (50 FPS)
    @Scheduled(fixedRate = 20)
    public void gameLoop() {
        if (sessions.isEmpty()) return; // Nu consumăm resurse dacă nu e nimeni conectat

        state.update(); // 1. Mișcăm mingea, verificăm coliziuni (în GameState)
        broadcast();    // 2. Trimitem noua stare către toți jucătorii
    }

    public void updatePaddle(double y) {
        state.setP1Y(y); // Jucătorul mișcă paleta (presupunem că P1Y e jucătorul)
    }

    public void restartGame() {
        state = new GameState();
    }

    private void broadcast() {
        // Construim JSON-ul exact așa cum îl așteaptă Flutter
        String json = String.format(
                "{\"ballX\": %f, \"ballY\": %f, \"p1Y\": %f, \"p2Y\": %f, \"scoreAI\": %d, \"scorePlayer\": %d, \"message\": \"%s\"}",
                state.getBallX(), state.getBallY(),
                state.getP1Y(), state.getP2Y(),
                state.getScoreAI(), state.getScorePlayer(),
                state.getMessage() == null ? "" : state.getMessage()
        );

        for (WebSocketSession s : sessions) {
            try {
                if (s.isOpen()) {
                    s.sendMessage(new TextMessage(json));
                }
            } catch (IOException e) {
                sessions.remove(s);
            }
        }
    }
}