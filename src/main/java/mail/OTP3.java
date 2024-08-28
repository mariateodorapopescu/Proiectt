package mail;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class OTP3 extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String sessionOtp = (String) session.getAttribute("otp");
        String userOtp = request.getParameter("userOtp");
        String page = request.getParameter("page");
        if (userOtp.equals(sessionOtp)) {
            session.removeAttribute("otp"); // Clear the OTP from the session after successful verification
            if (page != null) {
	            if (page.compareTo("2") == 0) {
	            	response.sendRedirect("modifpasd2.jsp"); 
	            	return;
	            } else if (page.compareTo("3") == 0) {
	            	response.sendRedirect("modifusr2.jsp"); 
	            	return;
	            } else {
	            response.sendRedirect("dashboard.jsp"); // Redirect to dashboard or success page
	            return;
	            }
            }
        } else {
            response.sendRedirect("otp.jsp?error=Invalid OTP");
        }
    }
}
