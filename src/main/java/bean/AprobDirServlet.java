package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AprobDirServlet extends HttpServlet {
    private AprobDirDao dep;

    public void init() {
        dep = new AprobDirDao();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doPost(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sesi = request.getSession(false); // This returns HttpSession directly
        if (sesi == null) {
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Sesiune nula!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }

        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser == null) {
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu e conectat niciun utilizator!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }

        String username = currentUser.getUsername();
        int idcon = Integer.parseInt(request.getParameter("idcon"));

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            int uid = getEmployeeIdFromLeave(idcon, conn);
            int uidc = getUserIdByUsername(username, conn);

//            if (uid == uidc) {
//                response.sendRedirect("login.jsp"); // Cannot approve own leave
//                return;
//            }
          
            dep.modif(idcon); // Assuming this method handles the modification of the leave status
            
            // trimit notificare la angajat
            GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
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
          	        stmt.setInt(1, idcon);
          	        
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
       	        stmt.setInt(1, idcon);
       	        
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
            
	          
	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message11 = "<h1>Felicitari! &#x1F389; <br> Concediul dvs. din data de " + data + " a fost aprobat! &#x1F389; </h1>"; 
	    	    
	    	    String message13 = "<h3>&#x1F4DD;Detalii despre acest concediu:</h3>";
	    	    String message14 = "<p><b>Inceput:</b> " + starto + "<br> <b>Final: </b> " + endo + "<br><b>Locatie:</b> " + loco + "<br><b> Motiv: </b>" + motivo + "<br><b>Tip concediu: </b>" + motivvo + "<br><b>Durata: </b>" + (durato) + " zile<br></p>";
	    	    
	    	    String message16 = "<p>Va dorim toate cele bune! &#x1F607; \r\n"
	    	    		+ " </p>";
	    	    String message1 = message11 + message13 + message14 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	   
	    	    try {
	    	        sender.send(subject1, message1, "liviaaamp@gmail.com", toa);
	    	       
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	       
	    	    }  
	    	    
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Aprobare cu succes!');");
		    out.println("window.location.href = 'vizualizareconcedii.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (SQLException e) {
            printSQLException(e);
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare la baza de date!');");
		    out.println("window.location.href = 'concediinoidir.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
        	e.printStackTrace();
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare - nu s-a gasit clasa, debug only!');");
		    out.println("window.location.href = 'concediinoidir.jsp';");
		    out.println("</script>");
		    out.close();
		}
    }

    private int getEmployeeIdFromLeave(int leaveId, Connection conn) throws SQLException {
        String query = "SELECT id_ang FROM concedii WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, leaveId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id_ang");
            }
        }
        return -1; // default or error case
    }

    private int getUserIdByUsername(String username, Connection conn) throws SQLException {
        String query = "SELECT id FROM useri WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return -1; // default or error case
    }

    private static void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
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
}
