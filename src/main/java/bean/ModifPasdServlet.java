package bean;

import jakarta.servlet.ServletException;
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

public class ModifPasdServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ModifPasdDao employeeDao;

    public void init() {
        employeeDao = new ModifPasdDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	int id = Integer.parseInt(request.getParameter("id"));
    	String cod =  request.getParameter("cnp");
    	if (cod != null) {
    		 String cod2 = null;
    	        try {
    	            Class.forName("com.mysql.cj.jdbc.Driver");
    	            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
    	                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT cnp FROM useri WHERE id = ?")) {
    	                preparedStatement.setInt(1, id);
    	                try (ResultSet rs = preparedStatement.executeQuery()) {
    	                    if (rs.next()) {
    	                        cod2 = rs.getString("cnp");
    	                    }
    	                }
    	            }
    	        } catch (ClassNotFoundException e) {
    				// TODO Auto-generated catch block
   				 response.setContentType("text/html;charset=UTF-8");
   				    PrintWriter out = response.getWriter();
   				    out.println("<script type='text/javascript'>");
   				    out.println("alert('Nu a gasit clasa - debug only!');");
   				    out.println("window.location.href = 'err.jsp';");
   				    out.println("</script>");
   				    out.close();
   				    e.printStackTrace();
   			} catch (SQLException e) {
   				// TODO Auto-generated catch block
   				response.setContentType("text/html;charset=UTF-8");
   				 PrintWriter out = response.getWriter();
   				    out.println("<script type='text/javascript'>");
   				    out.println("alert('Eroare la baza de date - debug only!');");
   				    out.println("window.location.href = 'err.jsp';");
   				    out.println("</script>");
   				    out.close();
   				    e.printStackTrace();
   			}
    	        if (cod2.compareTo(cod) != 0) {
    	        	response.setContentType("text/html;charset=UTF-8");
   				    PrintWriter out = response.getWriter();
   				    out.println("<script type='text/javascript'>");
   				    out.println("alert('Cod introdus gresit!');");
   				    out.println("window.location.href = 'forgotpass.jsp';");
   				    out.println("</script>");
   				    out.close();
    	        	return;
    	        }
    	}
        
        String password = request.getParameter("password");

        // Validate password
        if (!PasswordValidator.validatePassword(password)) {
        	PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nume de utilizator introdus gresit!');");
		    out.println("window.location.href = 'modifpasd2.jsp?p=true';");
		    out.println("</script>");
		    out.close();
        	// response.sendRedirect("modifpasd2.jsp?p=true");
        	return;
        }

        // Fetch username from the database using the ID
        String username = fetchUsernameById(id);
        // System.out.println(username);
        if (username == null) {
        	response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nume de utilizator introdus gresit!');");
			    out.println("window.location.href = 'forgotpass.jsp';");
			    out.println("</script>");
			    out.close();
        	return;
        }

        // Update password in database
        try {
            employeeDao.registerEmployee(password, username);
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'homedir.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'forgotpass.jsp';");
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
