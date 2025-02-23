package mail;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.Random;

public class OTP extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = request.getParameter("username");
        String token = (String) session.getAttribute("token");
        String page = request.getParameter("page");

        if (username == null || username.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=missing_username");
            return;
        }

        try {
            String otp = generateOTP();
            session.setAttribute("otp", otp);
            session.setAttribute("username", username);
            
            // Păstrăm token-ul în sesiune
            if (token != null) {
                session.setAttribute("token", token);
                // Setăm și în header pentru API calls
                System.out.println("TOKENUL ESTE: " + token); // V
                response.setHeader("Authorization", token);
            }

            String email = getUserEmail(username);
            if (email != null) {
                sendEmail(email, otp);
                redirectToOtpPage(response, page);
            } else {
                response.sendRedirect("login.jsp?error=User not found");
            }

        } catch (Exception e) {
            System.err.println("Error in OTP processing: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error processing OTP", e);
        }
    }

    // Restul metodelor rămân la fel
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private String generateOTP() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    private String getUserEmail(String username) throws Exception {
        String email = null;
        String query = "SELECT email FROM useri WHERE username = ?";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = connection.prepareStatement(query)) {
            
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    email = rs.getString("email");
                }
            }
        }
        return email;
    }

    private void redirectToOtpPage(HttpServletResponse response, String page) throws IOException {
        String redirectUrl = "otp.jsp";
        if (page != null) {
            switch (page) {
                case "2":
                    redirectUrl += "?page=2";
                    break;
                case "3":
                    redirectUrl += "?page=3";
                    break;
                default:
                    break;
            }
        }
        response.sendRedirect(redirectUrl);
    }

    private void sendEmail(String email, String otp) throws Exception {
        String subject = "\uD83D\uDD11 Cod verificare conectare \uD83D\uDD11";
        String message = "<h1>Codul este: " + otp + "</h1>" +
                        "<p>Discretia este recomandata! &#x1F642;</p>";
        
        GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
        sender.send(subject, message, "liviaaamp@gmail.com", email);
    }
}