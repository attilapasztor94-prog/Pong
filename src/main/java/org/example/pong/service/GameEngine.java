package org.example.pong.service;

import com.example.pong.model.GameState;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class GameEngine {
    private final GameState state = new GameState();
    private final CopyOnWriteArrayList<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
    private final ObjectMapper mapper = new ObjectMapper();

    public void addSession(WebSocketSession session) { sessions.add(session); }
    public void removeSession(WebSocketSession session) { sessions.remove(session); }
    public void updatePaddle(double y) { state.p1Y = y - 50; } // Centrează paleta

    @Scheduled(fixedRate = 16) // Rulează de ~60 de ori pe secundă
    public void gameLoop() {
        if (!state.message.isEmpty()) return;

        state.ballX += state.ballDX;
        state.ballY += state.ballDY;

        // Ricoșeu sus/jos (spațiul logic este 800x400)
        if (state.ballY <= 0 || state.ballY >= 380) state.ballDY *= -1;

        // Coliziune Jucător (DREAPTA)
        if (state.ballX >= 750 && state.ballY >= state.p1Y && state.ballY <= state.p1Y + 100) {
            state.ballDX = -Math.abs(state.ballDX) * 1.1;
        }

        // Coliziune AI (STÂNGA)
        state.p2Y += (state.ballY - (state.p2Y + 50)) * 0.15; // AI-ul urmărește mingea lin
        if (state.ballX <= 40 && state.ballY >= state.p2Y && state.ballY <= state.p2Y + 100) {
            state.ballDX = Math.abs(state.ballDX) * 1.1;
        }

        // Scor și Reset
        if (state.ballX < 0) {
            state.scorePlayer++;
            checkWinner();
            state.resetBall(true);
        } else if (state.ballX > 800) {
            state.scoreAI++;
            checkWinner();
            state.resetBall(false);
        }

        broadcastState();
    }

    private void checkWinner() {
        if (state.scorePlayer >= 5) state.message = "AI CÂȘTIGAT!";
        if (state.scoreAI >= 5) state.message = "AI PIERDUT!";
    }

    public void restartGame() {
        state.scorePlayer = 0; state.scoreAI = 0; state.message = "";
        state.resetBall(true);
    }

    private void broadcastState() {
        try {
            String json = mapper.writeValueAsString(state);
            TextMessage message = new TextMessage(json);
            for (WebSocketSession session : sessions) {
                if (session.isOpen()) session.sendMessage(message);
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}