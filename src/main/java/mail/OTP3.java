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
        String username = (String) session.getAttribute("username");
        if (userOtp.equals(sessionOtp)) {
            session.removeAttribute("otp"); // Clear the OTP from the session after successful verification
            try {
                // Actualizăm statusul de activ în baza de date
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    String updateQuery = "UPDATE useri SET activ = 1 WHERE username = ?";
                    try (PreparedStatement preparedStatement = connection.prepareStatement(updateQuery)) {
                        preparedStatement.setString(1, username);
                        preparedStatement.executeUpdate();
                    }
                }

            if (page != null) {
	            if (page.compareTo("2") == 0) {
	            	response.sendRedirect("modifpasd2.jsp"); 
	            	return;
	            } else if (page.compareTo("3") == 0) {
	            	response.sendRedirect("modifusr2.jsp"); 
	            	return;
	            } else {
	            	session.setAttribute("authenticated", "true");
	            	response.sendRedirect("dashboard.jsp"); // Redirect to dashboard or success page
	            return;
	            }
            }
         else {
            response.sendRedirect("otp.jsp?error=Invalid OTP");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=database");
    }

} else {
    response.sendRedirect("otp.jsp?error=Invalid OTP");
}
}
}
