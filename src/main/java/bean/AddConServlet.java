package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

import org.w3c.dom.Document;

//import com.itextpdf.pdf2data

import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AddConServlet extends HttpServlet {
//	private static final long serialVersionUID = 1L;
    
    public AddConServlet() {
        super();
    }
    
    private ConcediuConDao concediu;

    public void init() {
        concediu = new ConcediuConDao();
    }
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected Data toData(String data) {
		 String[] parts = data.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int uid = Integer.valueOf(request.getParameter("userId"));
		String start = request.getParameter("start");
		String end = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");
    	int tip = Integer.valueOf(request.getParameter("tip"));
    	int durata = 0;
    	 LocalDate start_c = LocalDate.parse(start);
		    LocalDate end_c = LocalDate.parse(end);
		    long daysBetween = ChronoUnit.DAYS.between(start_c, end_c) + 1; 
		    durata = (int) daysBetween + 1;
		    if (end_c.isBefore(start_c)) {
		        throw new IOException("Data de final nu poate fi inaintea celei de inceput!");
		    }

		    Set<LocalDate> holidays = new HashSet<>();
		    int year = start_c.getYear(); 
		    holidays.add(LocalDate.of(year, 1, 1)); 
		    holidays.add(LocalDate.of(year, 1, 2)); 
		    holidays.add(LocalDate.of(year, 1, 6)); 
		    holidays.add(LocalDate.of(year, 1, 7));
		    holidays.add(LocalDate.of(year, 1, 24)); 
		    holidays.add(LocalDate.of(year, 5, 1)); 
		    holidays.add(LocalDate.of(year, 6, 1)); 
		    holidays.add(LocalDate.of(year, 8, 15));
		    holidays.add(LocalDate.of(year, 11, 30)); 
		    holidays.add(LocalDate.of(year, 12, 1));
		    holidays.add(LocalDate.of(year, 12, 25));
		    holidays.add(LocalDate.of(year, 12, 26)); 
		    
		    //int duration = calculateDurationExcludingHolidaysAndNegativeStatus(uid, start_c, end_c);

        ConcediuCon con = new ConcediuCon();
        con.setId_ang(uid);
        con.setStart(start);
        con.setEnd(end);
        con.setMotiv(motiv);
        con.setLocatie(locatie);
        con.setTip(tip);
        con.setDurata((durata + 1));
      
        try {
			if (maimulteconcedii(request)) {
				 response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul nu poate avea mai mult de 3 perioade diefrite de concediu!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			 response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu a gasit clasa - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			response.setContentType("text/html;charset=UTF-8");
			 PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare IO - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		}
        
        try {
			if (!maimultezile(request)) {
				 response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul are deja prea multe zile de concediu!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			 response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu a gasit clasa - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			response.setContentType("text/html;charset=UTF-8");
			 PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare IO - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		}
        
        try {
			if (!odatavara(request) && (toData(con.getStart()).getLuna() >= 6 && toData(con.getStart()).getLuna() <= 8)) {
				 response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul nu poate avea mai mult de un concediu pe timpul verii!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			 response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu a gasit clasa - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			response.setContentType("text/html;charset=UTF-8");
			 PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare IO - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		}
        
        if (!maimultezileodata(con)) {
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
			out.println("<script type='text/javascript'>");
		    out.println("alert('Utilizatorul nu poate avea mai mult de 21 de zile / concediu!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			return;
		}
        
        try {
			if (!preamulti(con, request)) {
				 response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Au concediu prea multi utilizatori dintr-un singur departament!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			 response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu a gasit clasa - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			response.setContentType("text/html;charset=UTF-8");
			 PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare IO - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		}
        
        String QUERY2 = "select * from useri where id = ?;";
	    int userType = -1;
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY2)) {
		        stm.setInt(1, uid);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                userType = res.getInt("tip");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        response.setContentType("text/html;charset=UTF-8");
				 PrintWriter out = response.getWriter();
				    out.println("<script type='text/javascript'>");
				    out.println("alert('Eroare la baza de date - debug only!');");
				    out.println("window.location.href = 'actiuni.jsp';");
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
		        throw new IOException("Eroare la baza de date =(", e);
		    }
	    
	    if (userType == 0) {
	    	 try {
	 			if (!preamultid(con, request)) {
	 				 response.setContentType("text/html;charset=UTF-8");
	 				PrintWriter out = response.getWriter();
					out.println("<script type='text/javascript'>");
				    out.println("alert('Au concediu prea multi directori!');");
				    out.println("window.location.href = 'actiuni.jsp';");
				    out.println("</script>");
				    out.close();
					return;
				}
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				 response.setContentType("text/html;charset=UTF-8");
				    PrintWriter out = response.getWriter();
				    out.println("<script type='text/javascript'>");
				    out.println("alert('Nu a gasit clasa - debug only!');");
				    out.println("window.location.href = 'actiuni.jsp';");
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				response.setContentType("text/html;charset=UTF-8");
				 PrintWriter out = response.getWriter();
				    out.println("<script type='text/javascript'>");
				    out.println("alert('Eroare IO - debug only!');");
				    out.println("window.location.href = 'actiuni.jsp';");
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
			}
	    }
	    
	    if (userType == 0 || userType == 3) {
	    	con.setStatus(1);
	    } else {
	    	con.setStatus(0);
	    }
	    
	    if (concediuExista(uid, start_c, end_c)) {
	        response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Concediul specificat există deja!');");
	        out.println("window.location.href = 'actiuni.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
	    }
	    
	    try {
			if (oktip(con)) {
			    response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu poate avea mai multe zile decat tipul concediului!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    return; 
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    
        try {
            concediu.check(con);
            
            String tod = "";
            String tos = "";
            String toa = "";
            String nume = "";
            String prenume = "";
            String motivv = "";
            int tipp = -1;
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;"
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
    	    
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'concediinoieu.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut adauga concediul din motive necunoscute.');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}

	private boolean oktip(ConcediuCon con) throws SQLException {
		String start = con.getStart();
		String end = con.getEnd();
		LocalDate start_c = LocalDate.parse(start);
	    LocalDate end_c = LocalDate.parse(end);
	    long daysBetween = ChronoUnit.DAYS.between(start_c, end_c) + 1; 
	    int durata = 0;
	    durata = (int) daysBetween + 1;
	    int durata2 = 0;
		String QUERY = "select nr_zile from tipcon;";
	   
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY)) {
		        
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                durata2 = res.getInt("nr_zile");
		            }
		        }
		    } 
	    return durata2 < durata;
	}
	
	private boolean concediuExista(int uid, LocalDate start, LocalDate end) throws ServletException {
	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement stmt = connection.prepareStatement("SELECT COUNT(*) FROM concedii WHERE id_ang = ? AND start_c = ? AND end_c = ? and status >= 0")) {
	        stmt.setInt(1, uid);
	        stmt.setDate(2, java.sql.Date.valueOf(start));
	        stmt.setDate(3, java.sql.Date.valueOf(end));
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return rs.getInt(1) > 0;
	        }
	    } catch (SQLException e) {
	        throw new ServletException("Database error checking for existing leave", e);
	    }
	    return false;
	}

	
	private int calculateDurationExcludingHolidaysAndNegativeStatus(int userId, LocalDate start, LocalDate end) throws ServletException {
        Set<LocalDate> holidays = getLegalHolidays();
        Set<LocalDate> excludedDays = getDaysWithNegativeStatus(userId);
        int daysCount = 0;
        LocalDate current = start;
        while (!current.isAfter(end)) {
            if (!holidays.contains(current) && !excludedDays.contains(current)) {
                daysCount++;
            }
            current = current.plusDays(1);
        }
        return daysCount;
    }
	
    private Set<LocalDate> getDaysWithNegativeStatus(int userId) throws ServletException {
        Set<LocalDate> days = new HashSet<>();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stmt = connection.prepareStatement("SELECT start_c, end_c FROM concedii WHERE id_ang = ? AND status < 0")) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LocalDate start = rs.getDate("start_c").toLocalDate();
                    LocalDate end = rs.getDate("end_c").toLocalDate();
                    while (!start.isAfter(end)) {
                        days.add(start);
                        start = start.plusDays(1);
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("SQL Error", e);
        }
        return days;
    }

		private static void printSQLException(SQLException ex) {
	        for (Throwable e: ex) {
	            if (e instanceof SQLException) {
	                e.printStackTrace(System.err);
	                System.err.println("SQLState: " + ((SQLException) e).getSQLState());
	                System.err.println("Error Code: " + ((SQLException) e).getErrorCode());
	                System.err.println("Message: " + e.getMessage());
	                Throwable t = ex.getCause();
	                while (t != null) {
	                    System.out.println("Cause: " + t);
	                    t = t.getCause();
	                }
	            }
	        }
	    }
		
		public static boolean maimulteconcedii(HttpServletRequest request) throws ClassNotFoundException, IOException {
		    int nr = 0;
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    String QUERY = "SELECT * FROM useri WHERE useri.id = ?;";
		    int uid = Integer.valueOf(request.getParameter("userId"));

		    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
		        preparedStatement.setInt(1, uid);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            if (rs.next()) {
		                nr = rs.getInt("conramase"); // aici da, le ia pe alea cu status pozitiv sau 0
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }

		    return nr > 3;
		}

		public static boolean maimultezile(HttpServletRequest request) throws ClassNotFoundException, IOException {
		    int nr = 0;
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    int uid = Integer.valueOf(request.getParameter("userId"));
		    String QUERY2 = "select * from useri where id = ?;";
		    int userType = 0;
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			         PreparedStatement stm = conn.prepareStatement(QUERY2)) {
			        stm.setInt(1, uid);
			        try (ResultSet res = stm.executeQuery()) {
			            if (res.next()) {
			                userType = res.getInt("tip");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Eroare la baza de date", e);
			    }

		    Set<LocalDate> holidays = getLegalHolidays();
		    String QUERY = "SELECT start_c, end_c FROM concedii WHERE id_ang = ? and status >= 0;";

		    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
		        preparedStatement.setInt(1, uid);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            while (rs.next()) {
		                LocalDate start = rs.getDate("start_c").toLocalDate();
		                LocalDate end = rs.getDate("end_c").toLocalDate();
		                while (!start.isAfter(end)) {
		                    if (!holidays.contains(start)) {
		                        nr++;
		                    }
		                    start = start.plusDays(1);
		                }
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }
		    if (userType == 2) {
		        return nr < 30;
		    }
		    return nr < 40;
		}
		
		public static Set<LocalDate> getLegalHolidays() {
		    return new HashSet<>(Arrays.asList(
		        LocalDate.of(LocalDate.now().getYear(), 1, 1),
		        LocalDate.of(LocalDate.now().getYear(), 1, 2),
		        LocalDate.of(LocalDate.now().getYear(), 1, 6),
		        LocalDate.of(LocalDate.now().getYear(), 1, 7),
		        LocalDate.of(LocalDate.now().getYear(), 1, 24),
		        LocalDate.of(LocalDate.now().getYear(), 5, 1),
		        LocalDate.of(LocalDate.now().getYear(), 6, 1),
		        LocalDate.of(LocalDate.now().getYear(), 8, 15),
		        LocalDate.of(LocalDate.now().getYear(), 11, 30),
		        LocalDate.of(LocalDate.now().getYear(), 12, 1),
		        LocalDate.of(LocalDate.now().getYear(), 12, 25),
		        LocalDate.of(LocalDate.now().getYear(), 12, 26)
		    ));
		}
		
		public static boolean odatavara(HttpServletRequest request) throws ClassNotFoundException, IOException{
			 int nr = 0;
			    Class.forName("com.mysql.cj.jdbc.Driver");
			    String QUERY = "SELECT count(*) as total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE id_ang = ? AND MONTH(start_c) >=6 AND MONTH(start_c) <= 8 and concedii.status >= 0;";
			    int uid = Integer.valueOf(request.getParameter("userId"));

			    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
			        preparedStatement.setInt(1, uid);
			        try (ResultSet rs = preparedStatement.executeQuery()) {
			            if (rs.next()) {
			                nr = rs.getInt("total");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Eroare la baza de date", e);
			    }

			    return nr < 1;
		}
		
		public static boolean maimultezileodata(ConcediuCon concediu) {
		    LocalDate start_c = LocalDate.parse(concediu.getStart());
		    LocalDate end_c = LocalDate.parse(concediu.getEnd());

		    Set<LocalDate> holidays = getLegalHolidays();
		    
		    int countDays = 0;
		    LocalDate current = start_c;
		    while (!current.isAfter(end_c)) {
		    	
		        if (!holidays.contains(current)) {
		            countDays++;
		        }
		        current = current.plusDays(1);
		    }

		    return countDays < 21;
		}
		
		public static Data stringToDate(String dateString) {
	        String[] parts = dateString.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
	    }
		
		public static boolean preamulti(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException {
		    int nr = -1;
		    int total = -1;
		    int depid = -1;

		    Class.forName("com.mysql.cj.jdbc.Driver");

		    // Get the department ID first
		    String queryUserDep = "SELECT id_dep FROM useri WHERE id = ?";
		    int uid = Integer.parseInt(request.getParameter("userId"));

		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtUserDep = conn.prepareStatement(queryUserDep)) {
		        stmtUserDep.setInt(1, uid);
		        try (ResultSet rsUserDep = stmtUserDep.executeQuery()) {
		            if (rsUserDep.next()) {
		                depid = rsUserDep.getInt("id_dep");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date la departament", e);
		    }
		    System.out.println(depid);
		    // Check total users in department
		    String queryTotalUsers = "SELECT COUNT(*) AS total FROM useri WHERE id_dep = ?";
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtTotalUsers = conn.prepareStatement(queryTotalUsers)) {
		        stmtTotalUsers.setInt(1, depid);
		        try (ResultSet rsTotalUsers = stmtTotalUsers.executeQuery()) {
		            if (rsTotalUsers.next()) {
		                total = rsTotalUsers.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date cand numara utilizatorii din departament", e);
		    }
		    // Check total leaves in department within specific dates
		    String queryTotalLeaves = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON useri.id = concedii.id_ang " +
		        "WHERE useri.id_dep = ? AND start_c >= ? AND end_c <= ? and status > 0";
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtTotalLeaves = conn.prepareStatement(queryTotalLeaves)) {
		        Data start_c = stringToDate(concediu.getStart());
		        Data end_c = stringToDate(concediu.getEnd());

		        stmtTotalLeaves.setInt(1, depid);
		        stmtTotalLeaves.setDate(2, java.sql.Date.valueOf(start_c.getAn() + "-" + start_c.getLuna() + "-" + start_c.getZi()));
		        stmtTotalLeaves.setDate(3, java.sql.Date.valueOf(end_c.getAn() + "-" + end_c.getLuna() + "-" + end_c.getZi()));
		        try (ResultSet rsTotalLeaves = stmtTotalLeaves.executeQuery()) {
		            if (rsTotalLeaves.next()) {
		                nr = rsTotalLeaves.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }
		    return nr < (total / 2);
		}
		
		public static boolean preamultid(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
				 int nr = 0;
				    Class.forName("com.mysql.cj.jdbc.Driver");
				    String QUERY = "select count(*) as total from concedii join useri on useri.id = concedii.id_ang where day(start_c) >= ? and month(start_c) = ? and day(start_c) <= ? and month(start_c) <= ? and status > 0 group by useri.tip having useri.tip = 0;";
				  
				    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
				         PreparedStatement stm = con.prepareStatement(QUERY)) {
				        Data start_c = stringToDate(concediu.getStart());
				        Data end_c = stringToDate(concediu.getEnd());
				        stm.setInt(1, start_c.getZi());
				        stm.setInt(2, start_c.getLuna());
				        stm.setInt(3, end_c.getZi());
				        stm.setInt(4, end_c.getLuna());
				        try (ResultSet rs = stm.executeQuery() ) {
				            if (rs.next()) {
				                nr = rs.getInt("total");
				            }
				        }
				    } catch (SQLException e) {
				        printSQLException(e);
				        throw new IOException("Eroare la baza de date", e);
				    }

				    return nr < 2;
			}
}
