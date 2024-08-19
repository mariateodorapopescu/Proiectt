package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet implementation class OTP
 */
public class OTP2 extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public OTP2() {
        super();
        // TODO Auto-generated constructor stub
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
			}
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String cod = request.getParameter("oldotp");
		String cod2 = request.getParameter("newotp");
		String username = request.getParameter("username");
    	String password = request.getParameter("password");
		
		 if (cod2.compareTo(cod) == 0) {
			 
			 response.sendRedirect("login?username=" + username + "&password=" + password);
		 }
		 else response.sendRedirect("login.jsp?wup=1");
			}

}
