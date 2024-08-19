package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet pentru modificarea numelor departamentelor.
 */
public class ModifDepServlet extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
    private ModifDepDao dep;

    public void init() {
        dep = new ModifDepDao();
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String departament = request.getParameter("username");
        String old = request.getParameter("password");

        if (departament == null || old == null) {
            PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu s-au încărcat datele necesare pentru modificare!');");
 		    out.println("window.location.href = 'modifdeldep.jsp';");
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

            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare efectuată cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();

            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            asyncContext.setTimeout(1000);
            asyncContext.start(() -> {
                try {
                    MailAsincron.send4(old, departament);
                } catch (Exception e) {
                    asyncContext.getRequest().setAttribute("error", "Eroare la trimiterea email-ului: " + e.getMessage());
                }
                asyncContext.complete();
            });

        } catch (Exception e) {
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la modificare: " + e.getMessage() + "');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        }
    }
}
