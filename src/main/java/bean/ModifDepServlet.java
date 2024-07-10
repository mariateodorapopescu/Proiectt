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
public class ModifDepServlet extends HttpServlet {
    private ModifDepDao dep;

    public void init() {
        dep = new ModifDepDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String departament = request.getParameter("username");
        String old = request.getParameter("password");
        
        if (departament == null) {
        	System.out.println("nu-mi ia departamentu tu!!");
            //response.sendRedirect("login.jsp"); // Redirect or show error
            return;
        }

        if (!NameValidator.validateName(departament)) {
            response.sendRedirect("modifdep2.jsp?p=true");
            return;
        }

        try {
            dep.modif(departament, old);
            response.sendRedirect("adminok.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp");
        }
    }
}
