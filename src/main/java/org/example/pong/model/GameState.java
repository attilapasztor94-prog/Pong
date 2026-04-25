package org.example.pong.model;

public class GameState {
    private double ballX = 400, ballY = 200;
    private double ballDX = 5, ballDY = 5; // Viteza puțin mărită
    private double p1Y = 150, p2Y = 150;
    private int scorePlayer = 0, scoreAI = 0;
    private String message = "";
    private String playerName = "Jucător"; // Nume default

    public void setPlayerName(String name) {
        this.playerName = name;
    }

    public void update() {
        if (!message.isEmpty()) return; // Jocul se oprește dacă avem un câștigător

        ballX += ballDX;
        ballY += ballDY;

        // Ricoșeu sus/jos
        if (ballY <= 0 || ballY >= 380) ballDY *= -1;

        // Coliziune palete
        if (ballX <= 35 && ballY >= p2Y && ballY <= p2Y + 100) ballDX = Math.abs(ballDX);
        if (ballX >= 750 && ballY >= p1Y && ballY <= p1Y + 100) ballDX = -Math.abs(ballDX);

        // AI-ul urmărește mingea
        if (ballY > p2Y + 50) p2Y += 3.5;
        else p2Y -= 3.5;

        // Verificare scor
        if (ballX < 0) {
            scorePlayer++;
            checkWin();
            resetBall();
        }
        if (ballX > 800) {
            scoreAI++;
            checkWin();
            resetBall();
        }
    }

    private void checkWin() {
        // LIMITA DE 5 PUNCTE
        if (scorePlayer >= 5) {
            message = "AI-ul a câștigat!";
        } else if (scoreAI >= 5) {
            message = playerName + " a câștigat!";
        }
    }

    private void resetBall() {
        ballX = 400;
        ballY = 200;
        ballDX *= -1;
    }

    // Getters necesari pentru GameEngine
    public double getBallX() { return ballX; }
    public double getBallY() { return ballY; }
    public double getP1Y() { return p1Y; }
    public void setP1Y(double p1Y) { this.p1Y = p1Y; }
    public double getP2Y() { return p2Y; }
    public int getScorePlayer() { return scorePlayer; }
    public int getScoreAI() { return scoreAI; }
    public String getMessage() { return message; }
}