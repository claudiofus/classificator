package com.gruppoicse.beleaf.beleaf.control;

import jess.Rete;

public class EngineRunner extends Thread{
	Rete engine;
	boolean stopThread = false;
	boolean runEngine = false;
	
	public EngineRunner(Rete engine) {
		this.engine = engine;
		start();
	}
	
	@Override
	public void run() {		
		super.run();
		try {
			runEngine = true;
			while(!stopThread){
				if(runEngine){
					//avvia engine
					try {
						engine.run();
					} catch (Exception e){
						e.printStackTrace();
					}
					//runEngine = false;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void runEngine(){
		runEngine = true;
	}
// si può implementare la funzione di salvataggio della sessione tramite una funzione di jess che permette di salvare tutti i fatti della workingmemory su un file!
// obsoleto perchè l'engine ora viene usato una sola volta	
//	public void restart() throws JessException {
//		engine.reset();
//		runEngine = true;
//	}
//	
//	public void stopThread() {
//		stopThread = true;
//	}
}
