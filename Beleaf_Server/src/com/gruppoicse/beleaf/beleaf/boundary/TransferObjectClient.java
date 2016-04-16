package com.gruppoicse.beleaf.beleaf.boundary;

import java.io.Serializable;
import java.util.ArrayList;

import com.gruppoicse.beleaf.beleaf.entity.Risposta;

public class TransferObjectClient implements Serializable{
	private static final long serialVersionUID = 1L;
	
    public static final int RISPOSTA = 0;
    public static final int LISTA_RISPOSTE = 1;
    public static final int RICHIESTA_LISTA_RISPOSTE = 2;
    public static final int RESET = 3;
    private int tipoDato;
    private Risposta risposta;
    private ArrayList<Risposta>risposte;

    /**
     * Costruisce l'Oggetto che viene trasferito dal client al server
     * @param tipoDato tipo di dato che il server si deve aspettare
     * @param risposta inserire null in caso tipoDato != RISPOSTA
     */
    public TransferObjectClient(int tipoDato, Risposta risposta) {
        this.tipoDato = tipoDato;
        this.risposta = risposta;
    }

    public TransferObjectClient(int tipoDato, ArrayList<Risposta> risposte) {
        this.tipoDato = tipoDato;
        this.risposte = risposte;
    }
    
    public TransferObjectClient(int tipoDato){
        this.tipoDato = tipoDato;
    }

    public int getTipoDato() {
        return tipoDato;
    }

    public Risposta getRisposta() {
        return risposta;
    }
    
    public ArrayList<Risposta> getListaRisposte() {
    	return risposte;
    }
    
    @Override
    public String toString() {
    	
    	String string = "{ tipo toc: ";
    	if(this.tipoDato==RISPOSTA){
    		string = string.concat("risposta ").concat(this.risposta.getValore());
    	}
    	else if (this.tipoDato==LISTA_RISPOSTE){
    		string = string.concat("risposte");
    		for(Risposta risp : risposte){
    			string = string.concat(" | ").concat(risp.getNome()).concat(" ").concat(risp.getValore());
    		}
    	}
        else if(tipoDato==RESET){
            string = string.concat("reset");
        }
        else if(tipoDato==RICHIESTA_LISTA_RISPOSTE){
            string = string.concat("richiesta lista risposte");
        }
    	string = string.concat(" }"); 
    	return string;
    }
}