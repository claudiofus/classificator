package com.gruppoicse.beleaf.beleaf.boundary;


import java.io.Serializable;
import java.util.ArrayList;

import com.gruppoicse.beleaf.beleaf.entity.Domanda;
import com.gruppoicse.beleaf.beleaf.entity.Risposta;
import com.gruppoicse.beleaf.beleaf.entity.Soluzione;


public class TransferObjectServer implements Serializable{
	private static final long serialVersionUID = 1L;
	public final static int DOMANDA = 0;
	public final static int ALBERO_TROVATO = 1;
	public final static int ALBERO_SCONOSCIUTO = 2;
	public final static int LISTA_RISPOSTE = 3;

	private int tipoDato;
    private Domanda domanda;
    private ArrayList<Risposta> risposte;
    private Soluzione soluzione;

    public TransferObjectServer(int tipoDato, Domanda domanda, ArrayList<Risposta> risposte) {
        this.tipoDato = tipoDato;
        this.domanda = domanda;
        this.risposte = risposte;
    }

    public TransferObjectServer(int tipoDato, ArrayList<Risposta> risposte) {
        this.tipoDato = tipoDato;
        this.risposte = risposte;
    }
    
    public TransferObjectServer(int tipoDato, Soluzione soluzione) {
        this.tipoDato = tipoDato;
        this.soluzione = soluzione;
    }

    public TransferObjectServer(int tipoDato) {
        this.tipoDato = tipoDato;
    }
    
    public int getTipoDato() {
        return tipoDato;
    }

    public Domanda getDomanda() {
        return domanda;
    }

    public ArrayList<Risposta> getRisposte () {
        return risposte;
    }

    public Soluzione getSoluzione () { return soluzione; }
}
