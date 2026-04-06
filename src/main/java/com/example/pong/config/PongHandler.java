package com.example.pong.config;

import com.example.pong.service.GameEngine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component
public class PongHandler extends TextWebSocketHandler {
    @Autowired private GameEngine engine;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) { engine.addSession(session); }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) { engine.removeSession(session); }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String payload = message.getPayload();
        if (payload.equals("RESET")) {
            engine.restartGame();
        } else {
            try {
                engine.updatePaddle(Double.parseDouble(payload));
            } catch (NumberFormatException ignored) {}
        }
    }
}