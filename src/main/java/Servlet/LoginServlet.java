package Servlet;
import DAO.*;
import bean.*;
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

    public void init() {
        loginDao = new LoginDao();
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    		throws ServletException, IOException {
    	 String username = request.getParameter("username");
    	    String password = request.getParameter("password");
    	    MyUser loginBean = new MyUser();
    	    loginBean.setUsername(username);
    	    loginBean.setPassword(password);

    	    try {
    	        MyUser validatedUser = loginDao.validate(loginBean);
    	        if (validatedUser != null) {
    	            HttpSession session = request.getSession(false);
    	            
    	            if (session != null) {
    	                session.invalidate();
    	            }
    	            session = request.getSession(true);
    	            session.setAttribute("username", username);
    	            session.setAttribute("currentUser", validatedUser);
    	            response.sendRedirect(request.getContextPath() + "/OTP?username=" + username);
    	        } else {
    	            // Gestionare încercări de login eșuate
    	            HttpSession session = request.getSession(true);
    	            Integer loginAttempts = (Integer) session.getAttribute("loginAttempts");
    	            
    	            if (loginAttempts == null) {
    	                loginAttempts = 1;
    	            } else {
    	                loginAttempts++;
    	            }
    	            
    	            session.setAttribute("loginAttempts", loginAttempts);
    	            
    	            if (loginAttempts >= 3) {
    	                // Dacă sunt mai mult de 3 încercări, trimite la pagina de recuperare parolă
    	                response.sendRedirect("forgotpass.jsp");
    	            } else {
    	                // Altfel, întoarce-te la login cu mesaj de eroare
    	                response.sendRedirect("login.jsp?wup=true&loginAttempts=" + loginAttempts);
    	            }
    	        }
    	    } catch (Exception e) {
    	        // Orice excepție va redirecționa la login cu mesaj de eroare
    	        response.sendRedirect("login.jsp?wup=true");
    	    }
    }
}
