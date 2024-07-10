package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

//import bean.ModifUsrDao;
import bean.MyUser;
@WebServlet("/modifpasd")
public class ModifPasdServlet extends HttpServlet {
    private ModifPasdDao employeeDao;

    public void init() {
        employeeDao = new ModifPasdDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null) {
            response.sendRedirect("login.jsp"); // Redirect or show error
            return;
        }

        if (!PasswordValidator.validatePassword(password)) {
            response.sendRedirect("modifpasd2.jsp?p=true");
            return;
        }

        try {
            employeeDao.registerEmployee(password, username);
            response.sendRedirect("adminok.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp");
        }
    }
}
