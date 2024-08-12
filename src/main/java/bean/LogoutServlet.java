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
import java.sql.SQLException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logoutUser(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logoutUser(request, response);
    }

    private void logoutUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            HttpSession session = request.getSession();
            String INSERT_USERS_SQL = "UPDATE useri SET activ = 0 WHERE username = ?";
    	    int result = 0;
    	    Class.forName("com.mysql.cj.jdbc.Driver");
    	   
    	    String username = "";
    	    HttpSession sesi = request.getSession(false);
    	    if (sesi != null) {
    	        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    	        if (currentUser != null) {
    	            username = currentUser.getUsername();
    	        }
    	    }
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
    	         PreparedStatement preparedStatement1 = connection.prepareStatement(INSERT_USERS_SQL)) {
    	        
    	        preparedStatement1.setString(1, username);
    	        result = preparedStatement1.executeUpdate();
    	    } catch (SQLException e) {
    	        printSQLException(e);
    	    }
            session.setAttribute("currentUser", null); // It's better to invalidate the session
            session.invalidate(); // This clears the session and all attributes
            response.sendRedirect("login.jsp?logout=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu s-a putut face deconectare!');");
 		    out.println("window.location.href = 'deldep.jsp';");
 		    out.println("</script>");
 		    out.close();
        }
    }
    private void printSQLException(SQLException ex) {
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
}
