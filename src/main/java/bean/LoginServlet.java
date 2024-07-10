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
    private static final long serialVersionUID = 1;
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
    		            HttpSession session = request.getSession();
    		            session.setAttribute("currentUser", validatedUser);
    		            response.sendRedirect("intermediar.jsp");
    		        } else {
    		        	request.setAttribute("errorMessage", "Invalid username or password."); // Set error message
    		            response.sendRedirect("login.jsp?wup=true");
    		        }
    		    } catch (Exception e) {
    		       // e.printStackTrace();
    		        request.setAttribute("errorMessage", "Invalid username or password."); // Set error message
    		        response.sendRedirect("login.jsp?wup=true");
    		    }
    		}
}
