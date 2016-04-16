package com.gruppoicse.beleaf.beleaf.control;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;

public class DefinitionRetrieverHelper {

	private static HashMap <String,String> glossary = new HashMap<>();
	
	public static void init (){
		try {
			FileReader f = new FileReader("glossario.txt");
			BufferedReader in = new BufferedReader(f);
			String line;
			while((line = in.readLine()) != null)
			{
				String [] termDef = line.split("/");
				if (termDef.length == 2)
					glossary.put(termDef[0], termDef[1]);
			}				
			in.close();
			f.close();
		} catch (Exception e){
			e.printStackTrace();
		}
	}
	
	public static String getDefinition(String testoRisposta) {
		if (glossary.isEmpty())
			init();
		return glossary.get(testoRisposta);
	}
	
	public static boolean definitionAvailable (String testoRisposta) {
		if (glossary.isEmpty())
			init();
		return glossary.containsKey(testoRisposta);		
	}
}
