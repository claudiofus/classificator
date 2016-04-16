package com.gruppoicse.beleaf.beleaf.boundary;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.util.ArrayList;

import com.gruppoicse.beleaf.beleaf.control.JessController;
import com.gruppoicse.beleaf.beleaf.control.MessageParser;
import com.gruppoicse.beleaf.beleaf.entity.Risposta;

class ServeOneClient extends Thread {
	private Socket socket; //
	private ObjectOutputStream out; // output Stream
	private ObjectInputStream in; // input Stream
	JessController jc; 
	
	public ServeOneClient(Socket s){
		try {
			this.socket = s;
			out = new ObjectOutputStream(socket.getOutputStream());
			in = new ObjectInputStream(socket.getInputStream());
			start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void run() {
		System.out.println("ServeOneClient - Nuovo client connesso");
		try {
			
			//AVVIA MOTORE INFERENZIALE
			jc = new JessController();
			//INVIA MESSAGGIO INIZIALE
			out.writeObject(jc.ricevi().getTos());
			System.out.println("ServeOneClient - primo tos inviato al client");
			
			while (true) {
				try {
					//RICEVI MSG DA CLIENT
					TransferObjectClient toc = (TransferObjectClient)in.readObject();
					System.out.println("ServeOneClient - oggetto ricevuto dal client: " + toc.toString());
					
					switch (toc.getTipoDato()) {
						case TransferObjectClient.RISPOSTA:
							try {
								jc.rispondi(toc.getRisposta().getValore());
								out.writeObject(jc.ricevi().getTos());
								System.out.println("ServeOneClient - tos inviato al client (caso risposta)");
							} catch (Exception e) {
								System.out.println("ServeOneClient - ECCEZIONE (CASO RISPOSTA)");
								e.printStackTrace();
							}
							break;
	
						case TransferObjectClient.RESET: 
							try {
								jc.stop();
								jc=new JessController();
								out.writeObject(jc.ricevi().getTos());
								System.out.println("ServeOneClient - tos inviato al client (caso reset)");
							} catch (Exception e) {
								System.out.println("ServeOneClient - ECCEZIONE (CASO RESET)");
								e.printStackTrace();
							}
							break;
							
						case TransferObjectClient.RICHIESTA_LISTA_RISPOSTE:
							try {
								out.writeObject(jc.richiediListaRisposte().getTos());
								System.out.println("ServeOneClient - tos inviato al client (caso richiesta_lista_risposte)");
							} catch (Exception e){
								System.out.println("ServeOneClient - ECCEZIONE (CASO RICHIESTA_LISTA_RISPOSTE)");
								e.printStackTrace();
							}
							break;
							
						case TransferObjectClient.LISTA_RISPOSTE:
							try {
								ArrayList<String> risposteStr = new ArrayList<String>();
								for (Risposta risposta: toc.getListaRisposte())
									risposteStr.add(MessageParser.ripristinaUnderscore(risposta.getNome()));
								jc.ritrattaRisposte(risposteStr);
								out.writeObject(jc.ricevi().getTos());
								System.out.println("ServeOneClient - tos inviato al client (caso lista_risposte)");
							} catch (Exception e){
								System.out.println("ServeOneClient - ECCEZIONE (CASO LISTA_RISPOSTE)");
								e.printStackTrace();
							}
							break;
							
						default:
							System.out.println("ServeOneClient - ricevuto toc con \"tipoDato\" non valido.\ntipoDato: " + toc.getTipoDato());
					}// END SWITCH
				}//END TRY
				catch (IOException e) {
					//il client ha chiuso la comunicazione
					break;
				}
			}//END WHILE
		} 
		catch (Exception e) {
			System.out.println("ServeOneClient - ECCEZIONE DURANTE L'INVIO DEL PRIMO MESSAGGIO AL CLIENT");
			e.printStackTrace();
		}
		finally {
			try {
				socket.close();
				System.out.println("ServeOneClient - Socket chiusa: " + socket);
				if(jc!=null)
					jc.stop();
			} catch (IOException e) {
				System.err.println("ServeOneClient - Socket non chiusa! " + socket);
			}
		}
	}
}