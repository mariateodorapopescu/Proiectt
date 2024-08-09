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

//@WebServlet("/delusr")
public class DelUsrServlet extends HttpServlet {
    private DelUsrDao employeeDao;

    public void init() throws ServletException {
        try {
            employeeDao = new DelUsrDao();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DeldDao", e);
        }
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doPost(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	int id = Integer.parseInt(request.getParameter("id"));
    	String username = fetchUsernameById(id);
        if (username == null) {
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu se stie cine sa fie sters');");
 		    out.println("window.location.href = 'modifdel.jsp';");
 		    out.println("</script>");
 		    out.close();
        }

        try {
            employeeDao.deleteUser(username, id);
            
            String nume = null;
            String prenume = null;
            String email = null;
            int dep = -1;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement preparedStatement = connection.prepareStatement("SELECT email, nume, prenume, id_dep FROM useri WHERE id = ?")) {
                    preparedStatement.setInt(1, id);
                    try (ResultSet rs = preparedStatement.executeQuery()) {
                        if (rs.next()) {
                            nume = rs.getString("nume");
                            prenume = rs.getString("prenume");
                            email = rs.getString("email");
                            dep = rs.getInt("id_dep");
                        }
                    }
                }
            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
            }
            
         // trimit notificare la angajat
            GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
            String to = "";
           
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select email from useri where id_dep = ? and username != ?;"
       	         		+ "")) {
       	        stmt.setInt(1, dep);
       	        stmt.setString(2, username); 
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	        	while (rs.next()) {
       	        		to = rs.getString("email");
           	            

        	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
        	    	    String message11 = "<h1>Ultimile noutati </h1>"; 
        	    	    String message12 = "<h2>Colegul nostru de departament " + nume + " " + prenume + ", pleaca de la noi =( </h2>"; 
        	    	    
        	    	    String message16 = "<p>Sa ne luam ramas bun. &#x1F609;\r\n"
        	    	    		+ " <br> Doar suntem o familie! &#x1F917;\r\n"
        	    	    		+ " <br> Va dorim toate cele bune! &#x1F607; \r\n"
        	    	    		+ " </p>";
        	    	    String message1 = message11 + message12 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
        	    	    		+ "</i></b>";
        	    	   
        	    	    try {
        	    	        sender.send(subject1, message1, "liviaaamp@gmail.com", to);
        	    	       
        	    	    } catch (Exception e) {
        	    	        e.printStackTrace();
        	    	       
        	    	    }  
                    
       	        	}
       	            
       	        }
       	    } catch (SQLException e) {
       	        throw new ServletException("Eroare BD =(", e);
       	    } 
            
            String subject1 = "Ramas bun";
    	    String message11 = "<h1>Ne pare rau ca plecati de la noi... =( </h1>"; 
    	    String message12 = "<h2>Ne-a facut placere sa va avem in echipa! Sper sa ne auzim si cu alte ocazii! =) </h2>"; 
    	    
    	    String message16 = "<p>Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	    String message1 = message11 + message12 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
    	    		+ "</i></b>";
    	   
    	    try {
    	        sender.send(subject1, message1, "liviaaamp@gmail.com", email);
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	       
    	    }  
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge utilizatorul din motive necunoscute.');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    
    private String fetchUsernameById(int userId) {
        String username = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT username FROM useri WHERE id = ?")) {
                preparedStatement.setInt(1, userId);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        username = rs.getString("username");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return username;
    }
}
