package com.gruppoicse.beleaf.beleaf.control;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;

import com.gruppoicse.beleaf.beleaf.boundary.TransferObjectServer;
import com.gruppoicse.beleaf.beleaf.entity.Domanda;
import com.gruppoicse.beleaf.beleaf.entity.Risposta;
import com.gruppoicse.beleaf.beleaf.entity.Soluzione;

public class MessageParser {
	TransferObjectServer tos;
	//ogni stringa ricevuta dal motore inferenziale deve iniziare per una delle seguenti costanti seguita da uno spazio
	static private final String DOMANDA = "Q";
	static private final String ALBERO_TROVATO = "A";
	static private final String ALBERO_NON_TROVATO = "U";
	static private final String LISTA_RISPOSTE = "R";
	
	public MessageParser(String s) throws Exception {
		LinkedList<String> tokens = new LinkedList<String>(Arrays.asList(s.split(" ")));
		System.out.println("MessageParser - parsing oggetto ricevuto da Jess: "+ tokens.toString());
		String contenutoStringa = tokens.removeFirst();
			
		switch (contenutoStringa) {
		case DOMANDA:
		{	
			String domanda = new String();
			ArrayList<Risposta> risposte = new ArrayList<Risposta>();
			boolean fineDomanda = false; 
			boolean fineRisposte = false;
			for(String token : tokens) {
				if(!fineDomanda){
					domanda = domanda.concat(token + " ");
					fineDomanda = isFineDomanda(token);
				}
				else if (!fineRisposte) {
					String testoRisposta = eliminaUnderscore(purificaParentesi(token));
					if(DefinitionRetrieverHelper.definitionAvailable(purificaParentesi(token)))
						risposte.add(new Risposta(testoRisposta, ImageRetrieverHelper.getImage(testoRisposta), DefinitionRetrieverHelper.getDefinition(purificaParentesi(token))));
					else
						risposte.add(new Risposta(testoRisposta, ImageRetrieverHelper.getImage(testoRisposta)));
					fineRisposte = isFineRisposte(token);
				} 
			}
			
			if(!fineDomanda | !fineRisposte)
				throw new Exception ("MessageParser - Parse Exception: Domanda non valida: "+ s);
			//inserisci domanda e risposte nel tos
			tos = new TransferObjectServer(TransferObjectServer.DOMANDA, new Domanda(domanda), risposte);
		}
			break;
		
		case ALBERO_TROVATO:
		{
			String nomeAlbero = new String();
			String infoAlbero = new String();
			String why = new String();
			String altriCandidati = new String();
			boolean fineNome = false;
			boolean fineInfo = false;
			boolean fineWhy = false;
			boolean fineAltriCandidati = false;
			for (String token : tokens){ 
				if(!fineNome){
					nomeAlbero = nomeAlbero.concat(eliminaUnderscore(token));
					fineNome = isFineNomeAlbero(token);
				} 
				else if(!fineInfo){
					infoAlbero = infoAlbero.concat(token);
					infoAlbero = infoAlbero.concat(" ");
					fineInfo = isFineInfoAlbero(token);
				}
				else if(!fineWhy){
					why = why.concat(eliminaUnderscore(token));
					why = why.concat(" ");
					fineWhy = isFineWhy(token);
				}
				else if(!fineAltriCandidati){
					altriCandidati = altriCandidati.concat(eliminaUnderscore(token));
					fineAltriCandidati = isFineAltriCandidati(token);
				}
			}		
			nomeAlbero = nomeAlbero.replace("Albero:", "").replace("@","");
			infoAlbero = infoAlbero.replace("Info: ", "").replace("@","").replace("crlf ","\n");
			why = why.replace("Why: ", "").replace("@","").replace("crlf ","\n");
			altriCandidati = altriCandidati.replace("Altri:", "").replace(">","").replace("crlf", "\n");
			
			if(!fineNome | !fineInfo | !fineWhy | !fineAltriCandidati)
				throw new Exception ("MessageParser - Parse Exception: Soluzione non valida: "+ s);
			
			Soluzione soluzione;
			if(altriCandidati.isEmpty())
				soluzione = new Soluzione(ImageRetrieverHelper.getTreeImage(nomeAlbero), nomeAlbero, infoAlbero, why);
			else
				soluzione = new Soluzione(ImageRetrieverHelper.getTreeImage(nomeAlbero), nomeAlbero, infoAlbero, why, altriCandidati);
			tos = new TransferObjectServer(TransferObjectServer.ALBERO_TROVATO, soluzione);
		}
			break;
			
		case ALBERO_NON_TROVATO:
			tos = new TransferObjectServer(TransferObjectServer.ALBERO_SCONOSCIUTO);
			break;
		
		case LISTA_RISPOSTE:
		{
			ArrayList <Risposta> risposte = new ArrayList <Risposta>();
			for (int i = 0; i < tokens.size()-1; i+=2)
				risposte.add(new Risposta(eliminaUnderscore(tokens.get(i)),eliminaUnderscore(tokens.get(i+1))));
			tos = new TransferObjectServer(TransferObjectServer.LISTA_RISPOSTE, risposte);
		}
			break;
			
		default:
			throw new Exception("MessageParser - Parse Exception: Stringa non valida! Impossibile identificarne il contenuto. (la stringa deve iniziare per Q A o U): "+ s);
		}
	}

	private boolean isFineDomanda(String token){
		return token.endsWith("?");
	}
	
	private boolean isFineRisposte(String token){
		return token.endsWith(")");
	}
	
	private String purificaParentesi (String token){
		return token.replace("(", "").replace(")", "");
	}
	
	private boolean isFineNomeAlbero (String token){
		return token.endsWith("@");
	}
	private boolean isFineInfoAlbero(String token){
		return token.endsWith("@");
	}
	private boolean isFineWhy(String token){
		return token.endsWith("@");
	}
	private boolean isFineAltriCandidati(String token){
		return token.endsWith(">");
	}
	
	private String eliminaUnderscore (String token){
		return token.replace("_", " ");
	}
	
	public static String ripristinaUnderscore (String token){
		return token.replace(" ", "_");
	}
	
	public TransferObjectServer getTos() {
		return tos;
	}
}
