package org.example.pong.model;

public class GameState {
    private double paddleY = 0.5; // Poziția de start (mijloc)

    // Getter: Permite Engine-ului să citească valoarea pentru JSON
    public double getPaddleY() {
        return paddleY;
    }

    // Setter: Permite Engine-ului să modifice valoarea când primește date de la Flutter
    public void setPaddleY(double paddleY) {
        this.paddleY = paddleY;
    }
}