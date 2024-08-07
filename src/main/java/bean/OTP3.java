package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class OTP3 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String sessionOtp = (String) session.getAttribute("otp");
        String userOtp = request.getParameter("userOtp");

        if (userOtp.equals(sessionOtp)) {
            session.removeAttribute("otp"); // Clear the OTP from the session after successful verification
            response.sendRedirect("dashboard.jsp"); // Redirect to dashboard or success page
        } else {
            response.sendRedirect("otp.jsp?error=Invalid OTP");
        }
    }
}
