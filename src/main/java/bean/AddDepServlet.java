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

public class AddDepServlet extends HttpServlet {
//    private static final long serialVersionUID = 1;
    private DepDao depDao; // Correct the class name and variable

    public void init() {
        depDao = new DepDao(); // Initialize properly
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Debugging print removed
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String nume = request.getParameter("nume");
        
        if (!NameValidator.validateName(nume)) {
            response.sendRedirect("adddep.jsp?n=true");
            return;
        }
        
        try {
            depDao.addDep(nume); // Ensure this method exists and works in DepDao
            
         // trimit notificare la angajat
            GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
            String to = "";
           
            int tipp = -1;
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select tip, email from useri;"
       	         		+ "")) {
       	        
       	        
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	        	while (rs.next()) {
       	        		to = rs.getString("email");
           	            tipp = rs.getInt("tip");

        	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
        	    	    String message12 = "<h2>A fost adaugat un nou departament </h2>"; 
        	    	    String message11 = "<h1>Ultimile noutati </h1>"; 
        	    	    String message13 = "<h3>Sa vedem cum ne organizam!</h3>";
        	    	    String message16 = "<p>Decizia a fost luata la nivel de conducere. <br> Va dorim toate cele bune! &#x1F607; \r\n"
        	    	    		+ " </p>";
        	    	    String message1 = message11 + message12 + message13 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
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
       
           
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la adaugarea departamentului - motive necunoscute!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        }
    }
}