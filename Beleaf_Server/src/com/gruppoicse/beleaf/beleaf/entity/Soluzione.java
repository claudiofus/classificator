package com.gruppoicse.beleaf.beleaf.entity;

import java.io.Serializable;

public class Soluzione implements Serializable{
	private static final long serialVersionUID = 1L;
	
    private byte[] image;
    private String nome;
    private String info;
    private String why;
    private String altriCandidati;
    private boolean altriCandidatiPresenti;
    
	public Soluzione(byte[] image, String nomeAlbero, String infoAlbero, String why) {
		this.image = image;
		this.nome = nomeAlbero;
		this.info = infoAlbero;
		this.why = why;
		altriCandidatiPresenti = false;
	}

	public Soluzione(byte[] image, String nomeAlbero, String infoAlbero, String why, String altriCandidati) {
		this.image = image;
		this.nome = nomeAlbero;
		this.info = infoAlbero;
		this.why = why;
		this.altriCandidati = altriCandidati;
		this.altriCandidatiPresenti = true;
	}
	
	public byte[] getImage() {
		return image;
	}
	public String getNome() {
		return nome;
	}
	public String getInfo() {
		return info;
	}
	public String getWhy() {
		return why;
	}
	public boolean altriCandidatiPresenti(){
		return altriCandidatiPresenti;
	}
	public String getAltriCandidati(){
		return altriCandidati;
	}
}