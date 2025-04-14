package Servlet;
import bean.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
//import Filters.TokenBlacklist;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            try {
                String username = ((MyUser) session.getAttribute("currentUser")).getUsername();
                if (username != null) {
                    updateActiveStatus(username, false);
                }
                String authHeader = request.getHeader("Authorization");
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    String token = authHeader.substring(7);
                    // TokenBlacklist.blacklistToken(token);
                }
                session.invalidate(); // This clears the session and all attributes
                response.sendRedirect("login.jsp?logout=true");
            } catch (Exception e) {
                handleException(response, e);
            }
        } else {
            response.sendRedirect("login.jsp"); // Redirect to login page if session is already null
        }
    }

    private void updateActiveStatus(String username, boolean isActive) throws ClassNotFoundException, SQLException {
        String query = "UPDATE useri SET activ = 0 WHERE username = ?";
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            //preparedStatement.setInt(1, isActive ? 1 : 0);
            preparedStatement.setString(1, username);
            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
            throw e; // Rethrow the exception to handle it in the calling method
        }
    }

    private void handleException(HttpServletResponse response, Exception e) throws IOException {
        e.printStackTrace();
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<script type='text/javascript'>");
            out.println("alert('Nu s-a putut face deconectare!');");
            out.println("window.location.href = 'deldep.jsp';");
            out.println("</script>");
        }
    }

    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                System.err.println("SQLState: " + ((SQLException) e).getSQLState());
                System.err.println("Error Code: " + ((SQLException) e).getErrorCode());
                System.err.println("Message: " + e.getMessage());
                Throwable t = e.getCause();
                while (t != null) {
                    System.out.println("Cause: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}
