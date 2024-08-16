package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;

public class Async1 {
	public static void send(int uid, int tip, String start, String end, String motiv, String locatie, int durata) throws ServletException {
		String tod = "";
	    String tos = "";
	    String toa = "";
	    String nume = "";
	    String prenume = "";
	    String motivv = "";
	    int tipp = -1;
	    try (Connection connection1 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmt1 = connection1.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;"
		         		+ "")) {
		        stmt1.setInt(1, uid);
		        
		        ResultSet rs = stmt1.executeQuery();
		        if (rs.next()) {
		            tos = rs.getString("email_sef");
		            toa = rs.getString("email_ang");
		            tod = rs.getString("email_dir");
		            nume = rs.getString("nume_ang");
		            prenume = rs.getString("prenume_ang");
		            tipp = rs.getInt("tip");
		        }
		    } catch (SQLException e) {
		        throw new ServletException("Eroare BD =(", e);
		    }
	    
	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	  	         PreparedStatement stmt = connection.prepareStatement("select motiv from tipcon where tip = ?;")) {
	  	        stmt.setInt(1, tip);
	  	        
	  	        ResultSet rs = stmt.executeQuery();
	  	        if (rs.next()) {
	  	            motivv = rs.getString("motiv");
	  	            
	  	        }
	  	    } catch (SQLException e) {
	  	        throw new ServletException("Eroare BD=(", e);
	  	    }
	    
	    GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
	    
	    if (tipp != 0) {
	       // trimit confirmare inregistrare la angajat 
		    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message11 = "<h1>Felicitari! &#x1F389; Concediul a fost programat cu succes! &#x1F389;</h1>"; 
		    String message12 = "<h2>Totusi, acum mai trebuie sa asteptam confimarea acestuia &#x1F642; Sa fie intr-un ceas bun! &#x1F607;"
		    		+ "</h2>";
		    String message13 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message14 = "<p><b>Inceput:</b> " + start + "<br> <b>Final: </b> " + end + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message1 = message11 + message12 + message13 + message14 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		   
		    try {
		        sender.send(subject1, message1, "liviaaamp@gmail.com", toa);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	    if (tipp != 3 || tipp != 0) {
		 // trimit notificare la sef
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a adaugat un nou concediu."
		    		+ "</h2>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + start + "<br> <b>Final: </b> " + end + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		   
		    // GMailServer sender2 = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
	
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", tos);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    } 
	    if (tipp == 3){
	    	// trimit notificare la director
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a adaugat un nou concediu."
		    		+ "</h2>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + start + "<br> <b>Final: </b> " + end + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		   
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", tod);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	    if (tipp == 0){
	    	// trimit notificare la director ca angajat
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Felicitari! &#x1F389; Concediul a fost programat cu succes! &#x1F389; </h2><h3>Nu uitati sa-l aprobati sau sa-l respingeti!&#x1F609;\r\n"
		    		+ "</h3>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + start + "<br> <b>Final: </b> " + end + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
	
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", tod);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	}
}
