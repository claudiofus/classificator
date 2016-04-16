package com.gruppoicse.beleaf.beleaf.boundary;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class MultiServer extends Thread {
	public static final int PORT = 8080;
	
	public static void main(String[] args) {
		@SuppressWarnings("unused")
		MultiServer server = new MultiServer();
	}

	public MultiServer() {
		start();
		System.out.println("MultiServer - Server avviato.");
	}

	public void run() {
		try {
			// Starting Server
			ServerSocket s = new ServerSocket(PORT);
			// Server Started
			try {
				while (true) {
					//waiting for a connection
					Socket socket = s.accept();
					System.out.println("MultiServer - socket created: " + socket);
					// creating a ServerOneClient to serve the client
					new ServeOneClient(socket);
				}
			} finally {
				s.close();
				System.out.println("MultiServer - Server terminated.");
			}
		} catch (IOException e1) {
			e1.printStackTrace();
			System.err.println("MultiServer - Exception");
		}
	}
}