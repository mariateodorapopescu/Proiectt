package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

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
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu a incarcat departamentul!');");
 		    out.println("window.location.href = 'modifdep.jsp';");
 		    out.println("</script>");
 		    out.close();
            return;
        }

        if (!NameValidator.validateName(departament)) {
            response.sendRedirect("modifdep2.jsp?n=true");
            return;
        }

        try {
            dep.modif(departament, old);
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
}
