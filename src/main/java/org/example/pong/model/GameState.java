package org.example.pong.model;

public class GameState {
    public double ballX = 400, ballY = 200, ballDX = 7, ballDY = 7;
    public double p1Y = 150, p2Y = 150;
    public int scorePlayer =0, scoreAI = 0;
    public String message = "";

    public void resetBall(boolean toAI){
        ballX = 400; ballY = 200;
        ballDX = toAI ? -7 : 7;
        ballDY = Math.random() > 0.5 ? 7 : -7;

    }
}
