package com.gruppoicse.beleaf.beleaf.control;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ImageRetrieverHelper {

	private final static String imgDir = "immagini";
	private final static String attributeSubDir = "attributi";
	private final static String treeSubDir = "alberi";
	
	static public byte[] getImage(String answer){
		Path path = Paths.get(imgDir, attributeSubDir, answer + ".gif");
		if (Files.exists(path)){
			try {
				return Files.readAllBytes(path);
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}	
		} else {
			System.out.println("ImageRetrieverHelper - il file " + path + " non esiste!");
			return null;
		}
	}
	
	static public byte[] getTreeImage (String tree){
		Path path = Paths.get(imgDir, treeSubDir, tree + ".jpg");
		if (Files.exists(path)){
			try {
				return Files.readAllBytes(path);
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}
		} else {
			System.out.println("ImageRetrieverHelper - il file " + path + " non esiste!");
			return null;
		}
	}
}
