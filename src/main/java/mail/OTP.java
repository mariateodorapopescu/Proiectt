package mail;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;

/**
 * Servlet implementation class OTP
 */
public class OTP extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public OTP() {
        super();
    }

    private String generateOTP() {
        Random rnd = new Random();
        return String.format("%06d", rnd.nextInt(999999));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String username = request.getParameter("username");
        String email = "";

        String otp = generateOTP();
        session.setAttribute("otp", otp); // Store OTP in session
        session.setAttribute("username", username); // Store username in session
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String query = "SELECT email FROM useri WHERE username = ?";
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement(query)) {
                preparedStatement.setString(1, username);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        email = rs.getString("email");
                        sendEmail(email, otp); // Call to your existing email sending function
                        if (request.getParameter("page")!= null){
                        if (request.getParameter("page").compareTo("2") == 0) {
                        	 response.sendRedirect("otp.jsp?page=2"); // Redirect to OTP verification page
                        	 return;
                        }
                        else if (request.getParameter("page").compareTo("3") == 0) {
                       	 response.sendRedirect("otp.jsp?page=3"); // Redirect to OTP verification page
                       	 return;
                       }
                       else {
                       response.sendRedirect("otp.jsp"); // Redirect to OTP verification page
                       return;
                       }
                        } else {
                        	response.sendRedirect("otp.jsp"); // Redirect to OTP verification page
                            return;
                        }
                    } else {
                        response.sendRedirect("login.jsp?error=User not found");
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Error processing OTP", e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String username = request.getParameter("username");
        String email = "";

        String otp = generateOTP();
        session.setAttribute("otp", otp); // Store OTP in session
        session.setAttribute("username", username); // Store username in session
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String query = "SELECT email FROM useri WHERE username = ?";
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement(query)) {
                preparedStatement.setString(1, username);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        email = rs.getString("email");
                        sendEmail(email, otp); // Call to your existing email sending function
                        response.sendRedirect("otp.jsp?page=2"); // Redirect to OTP verification page
                    } else {
                        response.sendRedirect("login.jsp?error=User not found");
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Eroare OTP", e);
        }
    }
    
    private void sendEmail(String email, String otp) throws Exception {
        String subject = "\uD83D\uDD11 Cod verificare conectare \uD83D\uDD11";
        String message = "<h1>Codul este: " + otp + "</h1><p>Discretia este recomandata! &#x1F642;"
        		+ "</p>";
        GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
        
        sender.send(subject, message, "liviaaamp@gmail.com", email);
    }
}
