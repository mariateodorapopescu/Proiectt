package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
public class ResDirServlet extends HttpServlet {
    private ResDirDao dep;

    public void init() {
        dep = new ResDirDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = -1;
        id = Integer.valueOf(request.getParameter("idcon"));
        
        if (id == -1) {
            response.sendRedirect("login.jsp"); // Redirect or show error
            return;
        }

        try {
            dep.modif(id);
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp");
        }
    }
}
