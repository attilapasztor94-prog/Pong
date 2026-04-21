package org.example.pong.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    // Am făcut variabila 'final' și am șters @Autowired
    private final PongHandler pongHandler;

    // Acesta este constructorul.
    // Spring Boot știe automat să caute PongHandler și să îl bage aici.
    public WebSocketConfig(PongHandler pongHandler) {
        this.pongHandler = pongHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(pongHandler, "/ws").setAllowedOrigins("*");
    }
}