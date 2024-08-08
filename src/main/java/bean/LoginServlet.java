package bean;

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
    	        HttpSession session = request.getSession(false); // Get the existing session
    	        if (session != null) {
    	            session.invalidate(); // Invalidate the existing session if it exists
    	        }
    	        session = request.getSession(true); // Create a new session
    	        session.setAttribute("currentUser", validatedUser);
    	        session.setAttribute("username", username); // Store username in session
    	        response.sendRedirect("/Proiect/OTP?username=" + username); // Redirect to an intermediary page or dashboard
    	    } else {
    	    	
    	    	 Integer loginAttempts = (Integer) request.getSession(true).getAttribute("loginAttempts");
                 if (loginAttempts == null) {
                     loginAttempts = 1;
                 } else {
                     loginAttempts++;
                 }
                request.getSession(true).setAttribute("loginAttempts", loginAttempts);
                if (loginAttempts == 3) {
     	        	response.sendRedirect("login.jsp?rp=true&loginAttempts=" + loginAttempts);
     	        } else if (loginAttempts > 7) {
     	        	response.sendRedirect("forgotpass.jsp"); // Redirect back to the login page with error
     	        } else if (loginAttempts < 3) {
     	        	response.sendRedirect("login.jsp?loginAttempts=" + loginAttempts); // Redirect back to the login page with error
     	        }
     	        
    	    }
    	} catch (Exception e) {
    	    response.sendRedirect("login.jsp?wup=true"); // Redirect to the login page on exception
    	}
    }
}
