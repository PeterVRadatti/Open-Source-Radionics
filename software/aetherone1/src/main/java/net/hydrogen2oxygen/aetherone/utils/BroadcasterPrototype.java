package net.hydrogen2oxygen.aetherone.utils;


import processing.core.PApplet;
import processing.core.PImage;

import java.awt.*;

public class BroadcasterPrototype extends PApplet {

    public PImage bgImg;

    public static void main(String[] args) {

        PApplet.main("net.hydrogen2oxygen.aetherone.utils.BroadcasterPrototype");
    }

    @Override
    public void draw() {

        noStroke();

        if (bgImg != null) {
            background(bgImg);
        }

        fill(0, 0, 0);

        ellipse(50, 50, 80, 80);
    }

    @Override
    public void settings() {
        //fullScreen();
        size(480, 120);
    }

    @Override
    public void setup() {
        Font wFont = new Font("Courier", Font.PLAIN, 20);
    }

    public void init() {
    }
}
