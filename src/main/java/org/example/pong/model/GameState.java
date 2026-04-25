package org.example.pong.model;

public class GameState {
    // Dimensiunile câmpului de joc (trebuie să bată cu cele din Flutter: 800x400)
    private double ballX = 400, ballY = 200;
    private double ballDX = 4, ballDY = 4;
    private double p1Y = 150, p2Y = 150; // P1 este Jucătorul, P2 este AI
    private int scorePlayer = 0, scoreAI = 0;
    private String message = "";

    // Logica de mișcare a mingii (Game Loop)
    public void update() {
        if (!message.isEmpty()) return; // Joc oprit dacă avem mesaj (Win/Loss)

        ballX += ballDX;
        ballY += ballDY;

        // Coliziune sus/jos
        if (ballY <= 0 || ballY >= 380) ballDY *= -1;

        // Coliziune Paleta AI (Stânga - P2)
        if (ballX <= 35 && ballY >= p2Y && ballY <= p2Y + 100) {
            ballDX = Math.abs(ballDX); // Ricoșează la dreapta
        }

        // Coliziune Paleta Jucător (Dreapta - P1)
        if (ballX >= 750 && ballY >= p1Y && ballY <= p1Y + 100) {
            ballDX = -Math.abs(ballDX); // Ricoșează la stânga
        }

        // Logică AI simplă pentru P2 (urmărește mingea)
        if (ballY > p2Y + 50) p2Y += 3;
        else p2Y -= 3;

        // Scor și Reset
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

    private void resetBall() {
        ballX = 400; ballY = 200;
        ballDX *= -1; // Schimbă direcția la restart
    }

    private void checkWin() {
        if (scorePlayer >= 10) message = "AI-ul a pierdut!";
        if (scoreAI >= 10) message = "Ai pierdut!";
    }

    // GETTERS & SETTERS (Metodele pe care le căuta GameEngine)
    public double getBallX() { return ballX; }
    public double getBallY() { return ballY; }
    public double getP1Y() { return p1Y; }
    public void setP1Y(double p1Y) { this.p1Y = p1Y; }
    public double getP2Y() { return p2Y; }
    public int getScorePlayer() { return scorePlayer; }
    public int getScoreAI() { return scoreAI; }
    public String getMessage() { return message; }
}