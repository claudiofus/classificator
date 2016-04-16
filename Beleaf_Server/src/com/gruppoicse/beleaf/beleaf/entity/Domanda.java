package com.gruppoicse.beleaf.beleaf.entity;
import java.io.Serializable;

public class Domanda implements Serializable{
	private static final long serialVersionUID = 1L;
	
    private String text;

    public Domanda(String text) {
        this.text = text;
    }

    public String getText() {
        return text;
    }
}