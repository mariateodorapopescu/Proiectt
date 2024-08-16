package bean;
// importare librarii
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
// clasa ce se ocupa asincron de mailuri
public class MailAsincron {
	/**
	 * functie ce pregateste si trimmite mail in mod asincron pentru adaugarea unui concediu
	 * @param id
	 * @param tip
	 * @param inceput
	 * @param sfarsit
	 * @param motiv
	 * @param locatie
	 * @param durata
	 * @throws ServletException
	 */
	public static void send(int id, int tip, String inceput, String sfarsit, String motiv, String locatie, int durata) throws ServletException {
		// declarare si initializare variabile
		String director = "";
	    String sef = "";
	    String angajat = "";
	    String nume = "";
	    String prenume = "";
	    String motiv2 = "";
	    int tip2 = -1;
	    GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
	    
	    try (Connection conexiune1 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmt1 = conexiune1.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, "
		         		+ "ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef"
		         		+ " on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;");
	    		PreparedStatement stmt = conexiune1.prepareStatement("select motiv from tipcon where tip = ?;")) {
		        stmt1.setInt(1, id);
		        
		        ResultSet rezultat = stmt1.executeQuery();
		        if (rezultat.next()) {
		            sef = rezultat.getString("email_sef");
		            angajat = rezultat.getString("email_ang");
		            director = rezultat.getString("email_dir");
		            nume = rezultat.getString("nume_ang");
		            prenume = rezultat.getString("prenume_ang");
		            tip2 = rezultat.getInt("tip");
		        }
		        
		        stmt.setInt(1, tip);
	  	        
	  	        ResultSet rs = stmt.executeQuery();
	  	        if (rs.next()) {
	  	            motiv2 = rs.getString("motiv");     
	  	        }
	  	        
		    } catch (SQLException e) {
		        throw new ServletException("Eroare BD =(", e);
		    }

	    if (tip2 != 0) {
	       // trimit confirmare inregistrare la angajat 
		    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message11 = "<h1>Felicitari! &#x1F389; Concediul a fost programat cu succes! &#x1F389;</h1>"; 
		    String message12 = "<h2>Totusi, acum mai trebuie sa asteptam confimarea acestuia &#x1F642; Sa fie intr-un ceas bun! &#x1F607;"
		    		+ "</h2>";
		    String message13 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message14 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motiv2 + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message1 = message11 + message12 + message13 + message14 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		   
		    try {
		        sender.send(subject1, message1, "liviaaamp@gmail.com", angajat);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	    if (tip2 != 3 || tip2 != 0) {
		 // trimit notificare la sef
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a adaugat un nou concediu."
		    		+ "</h2>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motiv2 + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		 
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", sef);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    } 
	    if (tip2 == 3){
	    	// trimit notificare la director
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a adaugat un nou concediu."
		    		+ "</h2>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motiv2 + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
		   
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", director);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	    if (tip2 == 0){
	    	// trimit notificare la director ca angajat
		    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
		    
		    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
		    String message22 = "<h2>Felicitari! &#x1F389; Concediul a fost programat cu succes! &#x1F389; </h2><h3>Nu uitati sa-l aprobati sau sa-l respingeti!&#x1F609;\r\n"
		    		+ "</h3>";
		    String message23 = "<h3>&#x1F4DD;Detalii despre concediul programat:</h3>";
		    String message24 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motiv2 + "<br><b>Durata: </b>" + (durata - 1) + " zile<br></p>";
		    String message16 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
		    		+ " </p>";
		    String message2 = message21 + message22 + message23 + message24 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
		    		+ "</i></b>";
	
		    try {
		        sender.send(subject2, message2, "liviaaamp@gmail.com", director);
		       
		    } catch (Exception e) {
		        e.printStackTrace();
		       
		    }  
	    }
	}
	
	/**
	 * functie ce pregateste si trimmite mail in mod asincron pentru modificarea unui concediu
	 * @param id
	 * @param tip
	 * @param inceput
	 * @param sfarsit
	 * @param motiv
	 * @param locatie
	 * @param durata
	 * @throws ServletException
	 */
	public static void send2(int uid, int id, int tip, String inceput, String sfarsit, String motiv, String locatie, int durata, String inceputold, String sfarsitold, String locatieold, String motivold, String motivold2, int durataold2, String data) throws ServletException {
		// e diferit de cel de la adaugare, nu numai prin prinsma continutului mail-ului, ci si prin faptul ca am dat ca parametrii datele vechiului concediu, asa, ca un feature
		// trimit notificare la angajat
        String tod = "";
        String tos = "";
        String toa = "";
        String nume = "";
        String prenume = "";
        String motivv = "";
        int tipp = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
   	         PreparedStatement stmt = connection.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, "
   	         		+ "ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef "
   	         		+ "on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;"
   	         		+ "")) {
   	        stmt.setInt(1, uid);
   	        
   	        ResultSet rs = stmt.executeQuery();
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
        System.out.println(tos);
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
           // trimit confirmare modificare la angajat 
    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
    	    String message11 = "<h1>Felicitari! &#x1F389; Concediul dvs. din data de " + data + " a fost modificat cu succes! &#x1F389;</h1>"; 
    	    String message12 = "<h2>Totusi, acum mai trebuie sa asteptam confimarea acestuia &#x1F642; Sa fie intr-un ceas bun! &#x1F607;"
    	    		+ "</h2>";
    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
    	    String message14 = "<p><b>Inceput:</b> " + inceputold + "<br> <b>Final: </b> " + sfarsitold + "<br><b>Locatie:</b> " + locatieold + "<br><b> Motiv: </b>" + motivold + "<br><b>Tip concediu: </b>" + motivold2 + "<br><b>Durata: </b>" + durataold2 + " zile<br></p>";
    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
    	    String message16 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + durata + " zile<br></p>";
    	    String message17 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	    String message1 = message11 + message12 + message13 + message14 + message15 + message16 + message17 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
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
    	    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a modificat un concediu, mai exact unul din data de " + data + "."
    	    		+ "</h2>";
    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
    	    String message14 = "<p><b>Inceput:</b> " + inceputold + "<br> <b>Final: </b> " + sfarsitold + "<br><b>Locatie:</b> " + locatieold + "<br><b> Motiv: </b>" + motivold + "<br><b>Tip concediu: </b>" + motivold2 + "<br><b>Durata: </b>" + durataold2 + " zile<br></p>";
    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
    	    String message16 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + durata + " zile<br></p>";
    	    String message17 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + message17 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
    	    		+ "</i></b>";
    	   try {
    	        sender.send(subject2, message1, "liviaaamp@gmail.com", tos);
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	    }  
	    } 
	    
	    if (tipp == 3){
	    	// trimit notificare la director
    	    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
    	    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
    	    String message22 = "<h2>Angajatul " + nume + " " + prenume + " a modificat un concediu, mai exact unul din data de " + data + "."
    	    		+ "</h2>";
    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
    	    String message14 = "<p><b>Inceput:</b> " + inceputold + "<br> <b>Final: </b> " + sfarsitold + "<br><b>Locatie:</b> " + locatieold + "<br><b> Motiv: </b>" + motivold + "<br><b>Tip concediu: </b>" + motivold2 + "<br><b>Durata: </b>" + durataold2 + " zile<br></p>";
    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
    	    String message16 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + durata + " zile<br></p>";
    	    String message17 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + message17 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
    	    		+ "</i></b>";
    	    try {
    	        sender.send(subject2, message1, "liviaaamp@gmail.com", tod);
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	    }  
	    }
	    
	    if (tipp == 0){
	    	// trimit notificare la director ca angajat
    	    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";

    	    String message21 = "<h1>&#x26A0;&#xFE0F;Aveti un nou concediu de inspectat&#x26A0;&#xFE0F;</h1>"; 
    	    String message22 = "<h2>Felicitari! &#x1F389; Concediul din data de " + data + " a fost modificat cu succes! &#x1F389; </h2><h3>Nu uitati sa-l aprobati sau sa-l respingeti!&#x1F609;\r\n"
    	    		+ "</h3>";
    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
    	    String message14 = "<p><b>Inceput:</b> " + inceputold + "<br> <b>Final: </b> " + sfarsitold + "<br><b>Locatie:</b> " + locatieold + "<br><b> Motiv: </b>" + motivold + "<br><b>Tip concediu: </b>" + motivold2 + "<br><b>Durata: </b>" + durataold2 + " zile<br></p>";
    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
    	    String message16 = "<p><b>Inceput:</b> " + inceput + "<br> <b>Final: </b> " + sfarsit + "<br><b>Locatie:</b> " + locatie + "<br><b> Motiv: </b>" + motiv + "<br><b>Tip concediu: </b>" + motivv + "<br><b>Durata: </b>" + durata + " zile<br></p>";
    	    String message17 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	   
    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + message17 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
    	    		+ "</i></b>";
    	    try {
    	        sender.send(subject2, message1, "liviaaamp@gmail.com", tod);
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	       
    	    }  
	    }
	}
}
