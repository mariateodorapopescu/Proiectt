package mail;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import bean.MyUser;
import java.io.IOException;

public class OTP3 extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionOtp = (String) session.getAttribute("otp");
        String userOtp = request.getParameter("userOtp");
        String page = request.getParameter("page");
        String token = (String) session.getAttribute("token");
        System.out.println("TOKEN: " + token); //V
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        if (userOtp == null || sessionOtp == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (userOtp.equals(sessionOtp)) {
            session.removeAttribute("otp");

            if (token == null || currentUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            // Setăm doar token-ul în header pentru autentificare
            response.setHeader("Authorization", token);

            // Redirecționare bazată pe tip utilizator și pagină
            if (page != null) {
                switch (page) {
                    case "2":
                        response.sendRedirect("modifpasd2.jsp");
                        break;
                    case "3":
                        response.sendRedirect("modifusr2.jsp");
                        break;
                    default:
                    	response.sendRedirect("dashboard.jsp");
                        break;
                }
            } 
        } else {
            response.sendRedirect("otp.jsp?error=Invalid OTP");
        }
    }

   
}