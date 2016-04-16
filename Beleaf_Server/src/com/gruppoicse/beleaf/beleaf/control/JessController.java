package com.gruppoicse.beleaf.beleaf.control;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Calendar;

import com.gruppoicse.beleaf.beleaf.entity.RandomActivation;

import jess.JessException;
import jess.Rete;
import jess.awt.TextReader;

public class JessController {
	Rete engine;
	StringWriter fromJess;
	TextReader toJess;
	EngineRunner threadEngine;
	
	public static void main(String[] args){
		try {
			new JessController().ricevi();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public JessController() {

		//INIZIALIZZA VARIABILI
		fromJess = new StringWriter();
		toJess = new TextReader(false);
		
		//INIZIALIZZA MOTORE INFERENZIALE
		engine = new Rete();
		
		//INIZIALIZZA CANALI DI COMUNICAZIONE
		engine.addInputRouter("t", toJess, true);
		engine.addOutputRouter("t", fromJess);

		//AVVIA ESECUZIONE
		try {
			engine.setStrategy(new RandomActivation());
			engine.batch("domande.clp");
			engine.batch("alberi.clp");
			engine.reset();
			threadEngine = new EngineRunner(engine);
			System.out.println("JessController - Motore inferenziale avviato!");
			fornisciInformazioniIniziali();
		} catch (JessException e) {
			e.printStackTrace();
		}
	}

	private void fornisciInformazioniIniziali(){
		try {
			ricevi();//riceve la domanda riguardante il mese
			rispondi(asserisciMese());//risponde alla domanda
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private String asserisciMese(){
		String mesi[]= {"gennaio","febbraio","marzo","aprile","maggio","giugno","luglio","agosto","settembre","ottobre","novembre","dicembre"};
		return mesi[Calendar.getInstance().get(Calendar.MONTH)];
	}
	
	public MessageParser ricevi() throws Exception {
		String fromJessString = new String();
		//controlla che la stringa sia finita
		while (!fromJess.toString().contains(">"));
		fromJessString = fromJess.toString();
		fromJess.getBuffer().setLength(0);
		return new MessageParser(fromJessString);
	}
	
	public void rispondi(String risposta) {
		String risp = MessageParser.ripristinaUnderscore(risposta);
		System.out.println("JessController - risposta da inviare a Jess: " + risp);
		toJess.clear();
		toJess.appendText(risp+"\n");
	}
	
	public MessageParser richiediListaRisposte() {
		try {
			String command = ("(assert (richiesta lista_risposte))");
			engine.eval(command);
			threadEngine.runEngine();
			return ricevi();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public void ritrattaRisposte(ArrayList<String> risposte) {
		try {
			for(String risposta : risposte){
				String command = "(assert (richiesta ritratta_risposta " + risposta + "))"; 
				engine.eval(command);
			}
			threadEngine.runEngine();
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}
	
	@SuppressWarnings("deprecation")
	public void stop() {
		threadEngine.stop();
	}
}
