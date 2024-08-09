package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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

//import bean.ModifUsrDao;
import bean.MyUser;
public class ModifDepServlet extends HttpServlet {
    private ModifDepDao dep;

    public void init() {
        dep = new ModifDepDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String departament = request.getParameter("username");
        String old = request.getParameter("password");
        
        if (departament == null) {
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu a incarcat departamentul!');");
 		    out.println("window.location.href = 'modifdeldep.jsp';");
 		    out.println("</script>");
 		    out.close();
            return;
        }

        if (!NameValidator.validateName(departament)) {
            response.sendRedirect("modifdep2.jsp?n=true");
            return;
        }

        try {
            dep.modif(departament, old);
            
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
        	    	    String message11 = "<h1>Ultimile noutati </h1>"; 
        	    	    String message12 = "<h2>De acum incolo, departamentul " + old + " se va numi " + departament + " </h2>"; 
        	    	    
        	    	    String message16 = "<p>Decizia a fost luata la nivel de conducere. <br> Va dorim toate cele bune! &#x1F607; \r\n"
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
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
}
