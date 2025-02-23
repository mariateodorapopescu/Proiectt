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
        
        MyUser loginBean = new MyUser();
        loginBean.setUsername(username);
        loginBean.setPassword(password);

        try {
            MyUser validatedUser = loginDao.validate(loginBean);
            if (validatedUser != null) {
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
}