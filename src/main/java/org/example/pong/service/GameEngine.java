package org.example.pong.service;
import org.example.pong.model.GameState; // 2. IMPORTUL CORECTAT (nu mai e com.example)
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import java.io.IOException;
import java.util.concurrent.CopyOnWriteArrayList;

@Service // 3. Adnotarea care îl face vizibil pentru PongHandler
public class GameEngine {
    private final CopyOnWriteArrayList<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
    private GameState state = new GameState();

    public void addSession(WebSocketSession session) { sessions.add(session); }
    public void removeSession(WebSocketSession session) { sessions.remove(session); }

    public void updatePaddle(double y) {
        state.setPaddleY(y);
        broadcast();
    }

    public void restartGame() {
        state = new GameState();
        broadcast();
    }

    private void broadcast() {
        String json = String.format("{\"paddleY\": %f}", state.getPaddleY());
        for (WebSocketSession s : sessions) {
            try { s.sendMessage(new TextMessage(json)); } catch (IOException ignored) {}
        }
    }
}