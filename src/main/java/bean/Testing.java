package bean;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.TimerTask;
import java.time.LocalDate;
import java.util.ArrayList;
import jakarta.servlet.ServletException;

public class Testing extends TimerTask
{
	// private static Map<String, Long> lastSentMap = new HashMap<>();
	public void run()
	{
		 try {
	            Class.forName("com.mysql.cj.jdbc.Driver");
	            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
	                sendReminders(connection);
	                
	                sendReminders2(connection);
	                
	                sendReminders3(connection);
	                
	                sendReminders4(connection);
	                
	                sendReminders5(connection);
	                
	            } catch (IOException e) {
	                System.err.println("Error during database operation: " + e.getMessage());
	            } catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        } catch (ClassNotFoundException e) {
	            System.err.println("MySQL JDBC driver not found: " + e.getMessage());
	        }
				// System.out.println("ok");

	        }
	
	private void sendReminders(Connection connection) throws Exception {
	    String query = "select useri.id, useri.email, concedii.start_c, concedii.end_c, locatie, concedii.motiv, tipcon.motiv AS tip_motiv, tipcon.motiv as tip_motiv, DATEDIFF(concedii.start_c, CURRENT_DATE()) AS days_until_start "
	            + "FROM useri "
	            + "JOIN concedii ON useri.id = concedii.id_ang "
	            + "JOIN tipcon ON concedii.tip = tipcon.tip "
	            + "WHERE DATEDIFF(concedii.start_c, CURRENT_DATE()) BETWEEN 0 AND 1 AND concedii.status = 2;";
	    // mai are o zi pana la concediu

	    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
	        ResultSet rs = preparedStatement.executeQuery();
	        while (rs.next()) {
	            sendEmail(rs);
	        }
	    } catch (SQLException e) {
	        throw new IOException("Eroare BD: " + e.getMessage(), e);
	    }
	}
	
	private void sendReminders2(Connection connection) throws Exception {
	    String query = "SELECT id, nume, prenume, id_dep \r\n"
	    		+ "FROM useri \r\n"
	    		+ "WHERE DAY(data_nasterii) = DAY(CURRENT_DATE() + INTERVAL 1 DAY) \r\n"
	    		+ "  AND MONTH(data_nasterii) = MONTH(CURRENT_DATE() + INTERVAL 1 DAY);\r\n"
	    		+ "";
	    // email zi de nastere
	    String nume = "";
	    String prenume = "";
	    int id = -1;
	    int dep = -1;
	    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
	        ResultSet rs = preparedStatement.executeQuery();
	        while (rs.next()) {
	            nume = rs.getString("nume");
	            prenume = rs.getString("prenume");
	            dep = rs.getInt("id_dep");
	            id = rs.getInt("id");
	            String query2 = "SELECT email from useri where id_dep = " + dep + " and id <> " + id + ";";
	            try (PreparedStatement preparedStatement2 = connection.prepareStatement(query2)) {
	    	        ResultSet rs2 = preparedStatement2.executeQuery();
	    	        while (rs2.next()) {
	    	            sendEmail2(nume, prenume, rs2);
	    	        }
	    	    } catch (SQLException e) {
	    	        throw new IOException("Eroare BD: " + e.getMessage(), e);
	    	    }
	           
	        }
	    } catch (SQLException e) {
	        throw new IOException("Eroare BD: " + e.getMessage(), e);
	    }
	    
	}
	
	private void sendEmail2(String nume, String prenume, ResultSet rs) throws Exception {
		String to = rs.getString("email");
	   
	    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    String message21 = "<h1>Maine este ziua de nastere a lui " + nume + " " + prenume + "!&#x1F389;</h1>"; 
	    String message22 = "Sa-i uram \"La multi ani!\" impreuna! <br>";
	    String message23 = "<h2>Va dorim toate cele bune!&#x1F60E;</h2>";
	    String message222 = message21 + message22 + message23 + "<b><i>Conducerea firmei XYZ.</i></b>&#x1F917;";
	   
	    GMailServer sender = new GMailServer("liviaaamp@gmail.com","rtmz fzcp onhv minb");

	    try {
	        sender.send(subject2, message222, "liviaaamp@gmail.com", to);
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	       
	    }  
	    
	}
	
	private void sendReminders4(Connection connection) throws Exception {
	    String query = "SELECT email, id, nume, prenume, id_dep \r\n"
	    		+ "FROM useri \r\n"
	    		+ "WHERE DAY(data_nasterii) = DAY(CURRENT_DATE()) \r\n"
	    		+ "  AND MONTH(data_nasterii) = MONTH(CURRENT_DATE());\r\n"
	    		+ ";";
	    // email zi de nastere
	    String to = "";
	    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
	        ResultSet rs = preparedStatement.executeQuery();
	        while (rs.next()) {
	            to = rs.getString("email");
	            String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message21 = "<h1>La multi ani!&#x1F389;</h1>"; 
	    	    String message22 = "Compania va doreste multa sanatate, fericire si realizari pe toate planurile alaturi de cei dragi! &#x1F389; <br> Ne bucuram sa lucram impreuna cu dumneavoastra, sa va avem alaturi! Multumim pentru efortul depus! <br>";
	    	    String message23 = "<h2>Va dorim toate cele bune!&#x1F60E;</h2>";
	    	    String message222 = message21 + message22 + message23 + "<b><i>Conducerea firmei XYZ.</i></b>&#x1F917;";
	    	   
	    	    GMailServer sender = new GMailServer("liviaaamp@gmail.com","rtmz fzcp onhv minb");

	    	    try {
	    	        sender.send(subject2, message222, "liviaaamp@gmail.com", to);
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	    }  
	        }
	    } catch (SQLException e) {
	        throw new IOException("Eroare BD: " + e.getMessage(), e);
	    }
	    
	}
	
	private void sendReminders3(Connection connection) throws Exception {
	    String query = "SELECT nume \r\n"
	    		+ "FROM sarbatori \r\n"
	    		+ "WHERE DAY(zi - INTERVAL 1 DAY) = DAY(CURRENT_DATE()) \r\n"
	    		+ "  AND MONTH(zi) = MONTH(CURRENT_DATE())\r\n"
	    		+ "\r\n"
	    		+ "UNION\r\n"
	    		+ "\r\n"
	    		+ "SELECT nume \r\n"
	    		+ "FROM libere \r\n"
	    		+ "WHERE DAY(zi - INTERVAL 1 DAY) = DAY(CURRENT_DATE()) \r\n"
	    		+ "  AND MONTH(zi) = MONTH(CURRENT_DATE());";

	    String zi = "";

	    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
	        ResultSet rs = preparedStatement.executeQuery();
	        if (rs.next()) {
	            zi = rs.getString("nume");

	            String query2 = "SELECT email FROM useri";
	            try (PreparedStatement preparedStatement2 = connection.prepareStatement(query2);
	                 ResultSet rs2 = preparedStatement2.executeQuery()) {

	                while (rs2.next()) {
	                    String email = rs2.getString("email");
	                    sendEmail3(zi, email);
	                }
	            } catch (SQLException e) {
	                throw new IOException("Database error: " + e.getMessage(), e);
	            }
	        }
	    } catch (SQLException e) {
	        throw new IOException("Database error: " + e.getMessage(), e);
	    }
	}

	private void sendEmail3(String nume, String email) throws Exception {
	    String subject = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    String message = "<h1>Maine este " + nume + "!&#x1F389;</h1>" 
	                   + "Sa ne bucuram de aceasta zi impreuna! <br>" 
	                   + "<h2>Va dorim toate cele bune!&#x1F60E;</h2>"
	                   + "<b><i>Conducerea firmei XYZ.</i></b>&#x1F917;";

	    GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");

	    try {
	        sender.send(subject, message, "liviaaamp@gmail.com", email);
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}


	private void sendEmail(ResultSet rs) throws Exception {
		 System.currentTimeMillis();
		 
	    int id = rs.getInt("id");
	    String to = rs.getString("email");
	    // if (lastSentMap.containsKey(to) && (currentTimeMillis - lastSentMap.get(to)) < 3600000) {
        //     System.out.println(to + " a primit deja un email in ultima ora.");
        //    return;
        //}
	    Date startDate = rs.getDate("start_c");
	    Date endDate = rs.getDate("end_c");
	    rs.getInt("days_until_start");
	    String locatie = rs.getString("locatie");
	    String motiv = rs.getString("motiv");
	    String tipMotiv = rs.getString("tip_motiv");

	    SimpleDateFormat sdf = new SimpleDateFormat("EEEE dd MMMM yyyy", new Locale("ro", "RO"));
	    String formattedStart = sdf.format(startDate);
	    String formattedEnd = sdf.format(endDate);
	    
	    // -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	    
	    String subject = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    String message1 = "<h1>Mai aveti o zi pana la concediu!&#x1F389;</h1>"; 
	    String message2 = "Concediul e in perioada " + formattedStart + " - " + formattedEnd + " in " + locatie + " pe motivul " + motiv + " - " + tipMotiv + ". <br>";
	    String message3 = "<h2>Va dorim concediu placut!&#x1F60E;</h2>";
	    String message = message1 + message2 + message3 + "<b><i>Conducerea firmei XYZ.</i></b>&#x1F917;";
	   
	    GMailServer sender = new GMailServer(Constants.setFrom, Constants.setPassword);

	    try {
	        sender.send(subject, message, Constants.setFrom, to);
	        // lastSentMap.put(to, currentTimeMillis);
	        // System.out.println("S-a trimis mail la " + to);
	        //System.out.println("ok");
	    } catch (Exception e) {
	        e.printStackTrace();
	       // System.out.println("NOTok");
	    }  
	    
	    
	    String tod = "";
        String tos = "";
        String nume = "";
        String prenume = "";
        int tipp = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
   	         PreparedStatement stmt = connection.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;"
   	         		+ "")) {
   	        stmt.setInt(1, id);
   	        
   	        ResultSet rs2 = stmt.executeQuery();
   	        if (rs2.next()) {
   	            tos = rs2.getString("email_sef");
   	            rs2.getString("email_ang");
   	            tod = rs2.getString("email_dir");
   	            nume = rs2.getString("nume_ang");
   	            prenume = rs2.getString("prenume_ang");
   	            tipp = rs2.getInt("tip");
   	        }
   	    } catch (SQLException e) {
   	        throw new ServletException("Eroare BD =(", e);
   	    } 
        if (tipp != 0 || tipp != 3) {
           // trimit confirmare inregistrare la angajat 
    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
    	    String message11 = "<h1>Ultimile noutati </h1>"; 
    	    String message12 = "<h2>Angajatul " + nume + " " + prenume + " pleaca maine in concediu"
    	    		+ "</h2>";
    	    String message13 = "<h3>&#x1F4DD;Detalii despre concediu:</h3>";
    	    String message14 = "<p>Concediul e in perioada " + formattedStart + " - " + formattedEnd + " in " + locatie + " pe motivul " + motiv + " - " + tipMotiv + ". </p><br>";
    	    
    	    String message16 = "<p>Sa-i uram sejur placut/sa-i fim alaturi! Doar suntem ca o familie!  &#x2728;\r\n"
    	    		+ " </p>";
    	    String message4 = message11 + message12 + message13 + message14 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
    	    		+ "</i></b>";
    	   
    	    try {
    	        sender.send(subject1, message4, "liviaaamp@gmail.com", tos);
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	    }  
        }
        if (tipp == 3) {
            // trimit confirmare inregistrare la angajat 
     	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
     	    String message11 = "<h1>Ultimile noutati </h1>"; 
     	    String message12 = "<h2>Angajatul " + nume + " " + prenume + " pleaca maine in concediu"
     	    		+ "</h2>";
     	    String message13 = "<h3>&#x1F4DD;Detalii despre concediu:</h3>";
     	    String message14 = "<p>Concediul e in perioada " + formattedStart + " - " + formattedEnd + " in " + locatie + " pe motivul " + motiv + " - " + tipMotiv + ". </p><br>";
     	    
     	    String message16 = "<p>Sa-i uram sejur placut/sa-i fim alaturi! Doar suntem ca o familie!  &#x2728;\r\n"
     	    		+ " </p>";
     	    String message4 = message11 + message12 + message13 + message14 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
     	    		+ "</i></b>";
     	   
     	    try {
     	        sender.send(subject1, message4, "liviaaamp@gmail.com", tod);
     	       
     	    } catch (Exception e) {
     	        e.printStackTrace();
     	    }  
         }
	}
	
	private void sendReminders5(Connection connection) throws Exception {
			        
        HashMap<LocalDate, ArrayList<String>> onomastici = new HashMap<>();
        onomastici.put(LocalDate.of(2024, 1, 7), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 8, 15), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 12, 25), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 4, 23), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 11, 7), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 5, 21), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 11, 30), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 12, 27), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 6, 29), new ArrayList<>()); // Initialize with an empty ArrayList
        // onomastici.put(LocalDate.of(2024, 8, 21), new ArrayList<>()); // Initialize with an empty ArrayList
        onomastici.put(LocalDate.of(2024, 7, 7), new ArrayList<>()); // Initialize with an empty ArrayList
        
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ion");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ionut");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ioana");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Oana");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ionelia");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ionel");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ioneliu");
        onomastici.get(LocalDate.of(2024, 1, 7)).add("Ionela");
        
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Maria");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Mariana");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Maia");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Maya");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marinela");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marilena");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Mario");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marian");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marin");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marinel");
        onomastici.get(LocalDate.of(2024, 8, 15)).add("Marina");
        
        onomastici.get(LocalDate.of(2024, 12, 25)).add("Cristian");
        onomastici.get(LocalDate.of(2024, 12, 25)).add("Cristiana");
        onomastici.get(LocalDate.of(2024, 12, 25)).add("Cristina");
        onomastici.get(LocalDate.of(2024, 12, 25)).add("Christian");
        onomastici.get(LocalDate.of(2024, 12, 25)).add("Christina");
        
        onomastici.get(LocalDate.of(2024, 7, 7)).add("Teodor");
        onomastici.get(LocalDate.of(2024, 7, 7)).add("Theodor");
        onomastici.get(LocalDate.of(2024, 7, 7)).add("Teodora");
        
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Gheorghe");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("George");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Georgiana");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Georgeta");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Georgia");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Geanina");
        onomastici.get(LocalDate.of(2024, 4, 23)).add("Gianina");
        
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Mihai");
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Mihail");
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Mihaela");
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Gabriel");
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Gabriela");
        onomastici.get( LocalDate.of(2024, 11, 7)).add("Mihnea");
        
        onomastici.get(LocalDate.of(2024, 5, 21)).add("Constantin");
        onomastici.get(LocalDate.of(2024, 5, 21)).add("Costin");
        onomastici.get(LocalDate.of(2024, 5, 21)).add("Elena");
        
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andrei");
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andreia");
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andreea");
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andreas");
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andra");
        onomastici.get(LocalDate.of(2024, 11, 30)).add("Andrada");
        
        onomastici.get(LocalDate.of(2024, 12, 27)).add("Stefan");
        onomastici.get(LocalDate.of(2024, 12, 27)).add("Stefana");
        onomastici.get(LocalDate.of(2024, 12, 27)).add("Stefania");
        onomastici.get(LocalDate.of(2024, 12, 27)).add("Stefanuta");
        onomastici.get(LocalDate.of(2024, 12, 27)).add("Stefanita");
        
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Paul");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Paula");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Pavel");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Petru");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Petrica");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Petruta");
        onomastici.get(LocalDate.of(2024, 6, 29)).add("Petrut");
        
        //onomastici.get(LocalDate.of(2024, 8, 21)).add("Monica");
	    for (LocalDate i : onomastici.keySet()) {
	    	for (String j : onomastici.get(i)) {
		    String query = "select email from useri where day(current_date())=" + i.getDayOfMonth() + " and month(current_date())= " + i.getMonthValue() + " and prenume like \"" + "%" + j + "%\"";
		    // select email from useri where day(current_date())=21 and month(current_date())=8 and prenume like "%Monica%";
		   
		    String email = "";
	
			    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
			        ResultSet rs = preparedStatement.executeQuery();
			        if (rs.next()) {
			            email = rs.getString("email");
			            sendEmail5(email);
			        }
			    } catch (SQLException e) {
			        throw new IOException("Database error: " + e.getMessage(), e);
			    }
		    }
	    }
	}

	private void sendEmail5(String email) throws Exception {
	    String subject = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    String message = "<h1>La multi ani cu ocazia zilei numelui!&#x1F389;</h1>" 
	                   + "Multa sanatate, succes, fericire si realizari pe toate planurile alaturi de cei dragi! <br>" 
	                   + "<b><i>Conducerea firmei XYZ.</i></b>&#x1F917;";

	    GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");

	    try {
	        sender.send(subject, message, "liviaaamp@gmail.com", email);
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}

}