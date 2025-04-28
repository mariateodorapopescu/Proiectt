package Servlet;

import DAO.*;
import bean.*;
import Filters.JwtUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private LoginDao loginDao;
    private JwtUtil jwtUtil;

    @Override
    public void init() {
        loginDao = new LoginDao();
        jwtUtil = new JwtUtil();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println("Login attempt for user: " + username); // Debug log
        
        // Verifica si dezactiveaza utilizatorii cu contracte incetate
        checkAndDeactivateTerminatedContracts();
        
        // Verifica daca utilizatorul are contract incetat
        if (hasTerminatedContract(username)) {
            System.out.println("User has terminated contract: " + username); // Debug log
            response.sendRedirect("login.jsp?terminated=true");
            return;
        }
        
        MyUser loginBean = new MyUser();
        loginBean.setUsername(username);
        loginBean.setPassword(password);

        try {
            MyUser validatedUser = loginDao.validate(loginBean);
            if (validatedUser != null) {
                // Verifica daca utilizatorul este activ
//                if (validatedUser.getActiv() != 1) {
//                    System.out.println("User account is inactive: " + username); // Debug log
//                    response.sendRedirect("login.jsp?inactive=true");
//                    return;
//                }
                
                System.out.println("User validated successfully"); // Debug log
                
                // Invalidate old session if exists
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                
                // Create new session
                session = request.getSession(true);
                session.setAttribute("username", username);
                session.setAttribute("currentUser", validatedUser);
                
                // Generate JWT token using JwtUtil
                String jwtToken = jwtUtil.generateToken(username);
                System.out.println("JWT Token generated"); // Debug log
                
                session.setAttribute("token", "Bearer " + jwtToken);
                
                // Redirect to OTP
                response.sendRedirect(request.getContextPath() + "/OTP?username=" + username);
                return;
            } else {
                System.out.println("User validation failed"); // Debug log
                
                // Handle failed login attempts
                HttpSession session = request.getSession(true);
                Integer loginAttempts = (Integer) session.getAttribute("loginAttempts");
                loginAttempts = (loginAttempts == null) ? 1 : loginAttempts + 1;
                session.setAttribute("loginAttempts", loginAttempts);
                
                if (loginAttempts >= 3) {
                    System.out.println("Too many login attempts, redirecting to password recovery"); // Debug log
                    response.sendRedirect("forgotpass.jsp");
                } else {
                    System.out.println("Login attempt " + loginAttempts + " failed"); // Debug log
                    response.sendRedirect("login.jsp?wup=true&loginAttempts=" + loginAttempts);
                }
            }
        } catch (Exception e) {
            System.out.println("Error during login: " + e.getMessage()); // Debug log
            e.printStackTrace();
            response.sendRedirect("login.jsp?wup=true");
        }
    }
    
    /**
     * Verifica daca utilizatorul are contract incetat.
     */
    private boolean hasTerminatedContract(String username) {
        Connection conn = null;
        try {
            // incarcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directa
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            String checkIncetariSql = "SELECT COUNT(*) as count FROM istoric_incetari i " +
                                    "JOIN useri u ON i.id_ang = u.id " +
                                    "WHERE u.username = ?";
            PreparedStatement checkIncetariPstmt = conn.prepareStatement(checkIncetariSql);
            checkIncetariPstmt.setString(1, username);
            ResultSet checkIncetariRs = checkIncetariPstmt.executeQuery();
            
            boolean hasTerminated = false;
            if (checkIncetariRs.next() && checkIncetariRs.getInt("count") > 0) {
                hasTerminated = true;
            }
            
            checkIncetariRs.close();
            checkIncetariPstmt.close();
            
            return hasTerminated;
        } catch (ClassNotFoundException e) {
            System.err.println("Driver MySQL negasit: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Verifica si dezactiveaza utilizatorii cu contracte incetate.
     */
    private void checkAndDeactivateTerminatedContracts() {
        Connection conn = null;
        try {
            // incarcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directa
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // 1. Dezactiveaza utilizatorii a caror data de incetare a contractului a trecut
            String updateSql = "UPDATE useri u " +
                              "JOIN istoric_incetari i ON u.id = i.id_ang " +
                              "SET u.activ = 0 " +
                              "WHERE i.data_incetare <= CURDATE() AND u.activ = 1";
            PreparedStatement updatePstmt = conn.prepareStatement(updateSql);
            int updatedRows = updatePstmt.executeUpdate();
            updatePstmt.close();
            
            if (updatedRows > 0) {
                System.out.println("Utilizatori dezactivati cu contracte incetate: " + updatedRows);
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("Driver MySQL negasit: " + e.getMessage());
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
