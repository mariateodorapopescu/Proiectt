package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import bean.ConcediuCon;
import bean.ConcediuConDao;
/**
 * Servlet implementation class AddConServlet
 */
public class ModifConServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ModifConServlet() {
        super();
        // TODO Auto-generated constructor stub
    }
    
    private ModifConDao concediu;

    public void init() {
        concediu = new ModifConDao();
    }
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//doGet(request, response);
//		int uid = Integer.valueOf(request.getParameter("userId"));
		int id = Integer.valueOf(request.getParameter("idcon"));
		int tip = Integer.valueOf(request.getParameter("tip"));
		String start = request.getParameter("start");
		String end = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");
    	int durata = 0;
   	 LocalDate start_c = LocalDate.parse(start);
		    LocalDate end_c = LocalDate.parse(end);
		    long daysBetween = ChronoUnit.DAYS.between(start_c, end_c); 
		    durata = (int) daysBetween;
        ConcediuCon con = new ConcediuCon();
        con.setId(id);
        con.setTip(tip);
//        con.setId_ang(uid);
        con.setStart(start);
        con.setEnd(end);
        con.setMotiv(motiv);
        con.setLocatie(locatie);
        con.setDurata(durata);
        
        int uid = -1;
        String QUERY3 = "select id_ang from concedii where id = ?;";
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); 
		         PreparedStatement stm = conn.prepareStatement(QUERY3)) {
		        stm.setInt(1, id);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                uid = res.getInt("id_ang");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }
        
	    try {
			if (!maimulteconcedii(request)) {
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
			if (!odatavara(request, con) && (toData(con.getStart()).getLuna() >= 6 && toData(con.getStart()).getLuna() <= 8)) {
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
        
        try {
            concediu.check(con);
            
            // trimit notificare la angajat
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
            
            // hai sa facem un before and after =)
            String starto = "";
            String endo = "";
            String loco = "";
            String motivo = "";
            String tipo = "";
            String motivvo = "";
            int tippo = -1;
            int durato = -1;
            String data = "";
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
          	         PreparedStatement stmt = connection.prepareStatement("select datediff(end_c, start_c) as durata from concedii where id = ?;"
          	         		+ "")) {
          	        stmt.setInt(1, id);
          	        
          	        ResultSet rs = stmt.executeQuery();
          	        if (rs.next()) {
          	            
          	            durato = rs.getInt("durata") + 1;
          	        }
          	    } catch (SQLException e) {
          	        throw new ServletException("Eroare BD =(", e);
          	    }
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select * from concedii where id = ?;"
       	         		+ "")) {
       	        stmt.setInt(1, id);
       	        
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	            starto = rs.getString("start_c");
       	            endo = rs.getString("end_c");
       	            loco = rs.getString("locatie");
       	            motivo = rs.getString("motiv");
       	            tippo = rs.getInt("tip");
       	            data = rs.getString("added");
       	        }
       	    } catch (SQLException e) {
       	        throw new ServletException("Eroare BD =(", e);
       	    }
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         	         PreparedStatement stmt = connection.prepareStatement("select motiv from tipcon where tip = ?;")) {
         	        stmt.setInt(1, tippo);
         	        
         	        ResultSet rs = stmt.executeQuery();
         	        if (rs.next()) {
         	            motivvo = rs.getString("motiv");
         	            
         	        }
         	    } catch (SQLException e) {
         	        throw new ServletException("Eroare BD=(", e);
         	    }
            
            if (tipp != 0) {
	           // trimit confirmare modificare la angajat 
	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message11 = "<h1>Felicitari! &#x1F389; Concediul dvs. din data de " + data + " a fost modificat cu succes! &#x1F389;</h1>"; 
	    	    String message12 = "<h2>Totusi, acum mai trebuie sa asteptam confimarea acestuia &#x1F642; Sa fie intr-un ceas bun! &#x1F607;"
	    	    		+ "</h2>";
	    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
	    	    String message14 = "<p>Inceput: " + starto + "<br> Final: " + endo + "<br>Locatie: " + loco + "<br> Motiv: " + motivo + "<br>Tip concediu: " + motivvo + "Durata: " + durato + " zile<br></p>";
	    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
	    	    String message16 = "<p>Inceput: " + start + "<br> Final: " + end + "<br>Locatie: " + locatie + "<br> Motiv: " + motiv + "<br>Tip concediu: " + motivv + "Durata: " + durata + " zile<br></p>";
	    	    String message1 = message11 + message12 + message13 + message14 + message15 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
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
	    	    String message14 = "<p>Inceput: " + starto + "<br> Final: " + endo + "<br>Locatie: " + loco + "<br> Motiv: " + motivo + "<br>Tip concediu: " + motivvo + "Durata: " + durato + " zile<br></p>";
	    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
	    	    String message16 = "<p>Inceput: " + start + "<br> Final: " + end + "<br>Locatie: " + locatie + "<br> Motiv: " + motiv + "<br>Tip concediu: " + motivv + "Durata: " + durata + " zile<br></p>";
	    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	    // GMailServer sender2 = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
	
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
	    	    String message14 = "<p>Inceput: " + starto + "<br> Final: " + endo + "<br>Locatie: " + loco + "<br> Motiv: " + motivo + "<br>Tip concediu: " + motivvo + "Durata: " + durato + " zile<br></p>";
	    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
	    	    String message16 = "<p>Inceput: " + start + "<br> Final: " + end + "<br>Locatie: " + locatie + "<br> Motiv: " + motiv + "<br>Tip concediu: " + motivv + "Durata: " + durata + " zile<br></p>";
	    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
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
	    	    String message14 = "<p>Inceput: " + starto + "<br> Final: " + endo + "<br>Locatie: " + loco + "<br> Motiv: " + motivo + "<br>Tip concediu: " + motivvo + "Durata: " + durato + " zile<br></p>";
	    	    String message15 = "<h3>&#x1F4DD;Detalii despre noua modificare:</h3>";
	    	    String message16 = "<p>Inceput: " + start + "<br> Final: " + end + "<br>Locatie: " + locatie + "<br> Motiv: " + motiv + "<br>Tip concediu: " + motivv + "Durata: " + durata + " zile<br></p>";
	    	    String message1 = message21 + message22 + message13 + message14 + message15 + message16 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	    try {
	    	        sender.send(subject2, message1, "liviaaamp@gmail.com", tod);
	    	       
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	       
	    	    }  
    	    }
            
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'concediinoieu.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'concediinoieu.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}
	
	protected Data toData(String data) {
		 String[] parts = data.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
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
	    
	    int id = Integer.valueOf(request.getParameter("idcon"));
	    int uid = -1;
        String QUERY3 = "select id_ang from concedii where id = ?;";
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY3)) {
		        stm.setInt(1, id);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                uid = res.getInt("id_ang");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }
	    
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    String QUERY = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE useri.id = ? and concedii.id <> ? and concedii.status >= 0;";
	    //int uid = Integer.valueOf(request.getParameter("userId"));

	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
	        preparedStatement.setInt(1, uid);
	        preparedStatement.setInt(2, id);
	        try (ResultSet rs = preparedStatement.executeQuery()) {
	            if (rs.next()) {
	                nr = rs.getInt("total");
	            }
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date =(", e);
	    }

	    return nr < 3;
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
		        throw new IOException("Eroare la baza de date =(", e);
		    }

	    Set<LocalDate> holidays = getLegalHolidays();
	    String QUERY = "SELECT start_c, end_c FROM concedii WHERE id_ang = ? and concedii.id <> ? and concedii.status >= 0;";
	    
	    int aidi = Integer.valueOf(request.getParameter("idcon"));

	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
	        preparedStatement.setInt(1, uid);
	        preparedStatement.setInt(2, aidi);
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
	public static boolean odatavara(HttpServletRequest request, ConcediuCon concediu) throws ClassNotFoundException, IOException{
		 int nr = 0;
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    String QUERY = "SELECT count(*) as total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE id_ang = ? AND MONTH(start_c) >=6 AND MONTH(start_c) <= 8 and concedii.id <> ? and concedii.status >= 0;";
//		    int uid = Integer.valueOf(request.getParameter("userId"));

		    int id = Integer.valueOf(request.getParameter("idcon"));
		    int uid = -1;
	        String QUERY3 = "select id_ang from concedii where id = ?;";
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
			         PreparedStatement stm = conn.prepareStatement(QUERY3)) {
			        stm.setInt(1, id);
			        try (ResultSet res = stm.executeQuery()) {
			            if (res.next()) {
			                uid = res.getInt("id_ang");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Eroare la baza de date =(", e);
			    }
		    
		    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
		        preparedStatement.setInt(1, uid);
		        preparedStatement.setInt(2, id);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            if (rs.next()) {
		                nr = rs.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date =(", e);
		    }

		    return nr < 1;
	}
	
	public static int contor(Data startt, Data endd) {
		int contor = 0;
        if (startt.getLuna() == endd.getLuna()) {
            contor = endd.getZi() - startt.getZi() + 1;
        } else {
            if (startt.getLuna() == 1 || startt.getLuna() == 3 || startt.getLuna() == 5 || startt.getLuna() == 7
                    || startt.getLuna() == 8 || startt.getLuna() == 10 || startt.getLuna() == 12) {
                contor = 31 - startt.getZi() + endd.getZi() + 1;
            } else if (startt.getLuna() == 4 || startt.getLuna() == 6 || startt.getLuna() == 9 || startt.getLuna() == 11) {
                contor = 30 - startt.getZi() + endd.getZi() + 1;
            } else {
                if (startt.getAn() % 4 == 0) {
                    contor = 29 - startt.getZi() + endd.getZi() + 1;
                } else {
                    contor = 28 - startt.getZi() + endd.getZi() + 1;
                }
            }
        }
        return contor;
    }
	
	public static boolean maimultezileodata(ConcediuCon concediu) {
		int nr = 0;
		 Data start_c = stringToDate(concediu.getStart());
	     Data end_c = stringToDate(concediu.getEnd());
	     nr = contor(start_c, end_c);
	     return nr < 21;
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
//	    int uid = Integer.parseInt(request.getParameter("userId"));

	    int id = Integer.valueOf(request.getParameter("idcon"));
	    int uid = -1;
        String QUERY3 = "select id_ang from concedii where id = ?;";
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY3)) {
		        stm.setInt(1, id);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                uid = res.getInt("id_ang");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date =(", e);
		    }
	    
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
	        throw new IOException("Eroare la baza de date =( ", e);
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
	        throw new IOException("Eroare la baza de date =(", e);
	    }
	    System.out.println(total);
	    // Check total leaves in department within specific dates
	    String queryTotalLeaves = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON useri.id = concedii.id_ang " +
	        "WHERE useri.id_dep = ? AND start_c >= ? AND end_c <= ? and concedii.id <> ? and concedii.status >= 0;";
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement stmtTotalLeaves = conn.prepareStatement(queryTotalLeaves)) {
	        Data start_c = stringToDate(concediu.getStart());
	        Data end_c = stringToDate(concediu.getEnd());

	        stmtTotalLeaves.setInt(1, depid);
	        stmtTotalLeaves.setDate(2, java.sql.Date.valueOf(start_c.getAn() + "-" + start_c.getLuna() + "-" + start_c.getZi()));
	        stmtTotalLeaves.setDate(3, java.sql.Date.valueOf(end_c.getAn() + "-" + end_c.getLuna() + "-" + end_c.getZi()));
	        stmtTotalLeaves.setInt(4, id);
	        try (ResultSet rsTotalLeaves = stmtTotalLeaves.executeQuery()) {
	            if (rsTotalLeaves.next()) {
	                nr = rsTotalLeaves.getInt("total");
	            }
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date =(", e);
	    }
	    System.out.println(nr);
	    return nr <= (total / 2);
	}
	
	public static boolean preamultid(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
			 int nr = 0;
			    int id = Integer.valueOf(request.getParameter("idcon"));
			    Class.forName("com.mysql.cj.jdbc.Driver");
			    String QUERY = "select count(*) as total from concedii join useri on useri.id = concedii.id_ang where day(start_c) >= ? and month(start_c) = ? and day(start_c) <= ? and month(start_c) <= ? group by tip having tip = 0 and concedii.id <> ? and concedii.status >= 0;";
			  
			    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			         PreparedStatement stm = con.prepareStatement(QUERY)) {
			        Data start_c = stringToDate(concediu.getStart());
			        Data end_c = stringToDate(concediu.getEnd());
			        stm.setInt(1, start_c.getZi());
			        stm.setInt(2, start_c.getLuna());
			        stm.setInt(3, end_c.getZi());
			        stm.setInt(4, end_c.getLuna());
			        stm.setInt(5, id);
			        try (ResultSet rs = stm.executeQuery() ) {
			            if (rs.next()) {
			                nr = rs.getInt("total");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Eroare la baza de date =(", e);
			    }

			    return nr < 2;
		}
	
    public static boolean validate(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
//    	int uid = Integer.valueOf(request.getParameter("userId"));
	    
    	int id = Integer.valueOf(request.getParameter("idcon"));
	    int uid = -1;
        String QUERY3 = "select id_ang from concedii where id = ?;";
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY3)) {
		        stm.setInt(1, id);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                uid = res.getInt("id_ang");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date =(", e);
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
		        throw new IOException("Eroare la baza de date =(", e);
		    }
	    
    	if (userType == 0) {
    		return maimulteconcedii(request) && maimultezile(request) && odatavara(request, concediu) & maimultezileodata(concediu) && preamulti(concediu, request) && preamultid(concediu, request);
    	} 
    	return maimulteconcedii(request) && maimultezile(request) && odatavara(request, concediu) && maimultezileodata(concediu) && preamulti(concediu, request);
    }
	

}
