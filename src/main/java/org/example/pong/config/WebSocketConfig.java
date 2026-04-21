package org.example.pong.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final PongHandler pongHandler;

    // Fiind în același pachet, Java îl găsește pe PongHandler fără import!
    public WebSocketConfig(PongHandler pongHandler) {
        this.pongHandler = pongHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // Aceasta este ușa prin care intră jocul tău (adresa /ws)
        registry.addHandler(pongHandler, "/ws")
                .setAllowedOriginPatterns("*");
    }
}