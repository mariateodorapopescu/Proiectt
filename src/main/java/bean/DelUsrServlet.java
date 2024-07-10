package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

//@WebServlet("/delusr")
public class DelUsrServlet extends HttpServlet {
    private DelUsrDao employeeDao;

    public void init() throws ServletException {
        try {
            employeeDao = new DelUsrDao();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DeldDao", e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        if (username == null) {
            response.sendRedirect("delusr1.jsp");
            return;
        }

        try {
            employeeDao.deleteUser(username);
            response.sendRedirect("adminok.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp");
        }
    }
}
