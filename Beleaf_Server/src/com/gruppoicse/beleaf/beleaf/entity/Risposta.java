package com.gruppoicse.beleaf.beleaf.entity;

import java.io.Serializable;

public class Risposta implements Serializable{
	private static final long serialVersionUID = 1L;
	
	private String nome;
    private String valore;
    private byte[] image;
    
    private String definition;
    private boolean existsDefinition;
    public Risposta(String nome, String valore) {
        this.nome = nome;
    	this.valore = valore;
    	existsDefinition = false;
    }
    
    public Risposta(String valore, byte[] image, String definition) {
        this.valore = valore;
        this.image = image;
   		this.definition = definition;
   		existsDefinition = true;
    }
    public Risposta(String text, byte[] image) {
        this.valore = text;
        this.image = image;
        existsDefinition = false;
    }

    public String getNome() {
        return nome;
    }

    public String getValore() {
        return valore;
    }

    public byte[] getImage() {
        return image;
    }
    
    public String getDefinition(){
    	return definition;
    }
    public boolean existsDefinition(){
    	return existsDefinition;
    }
}