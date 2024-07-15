package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class AddDepServlet extends HttpServlet {
//    private static final long serialVersionUID = 1;
    private DepDao depDao; // Correct the class name and variable

    public void init() {
        depDao = new DepDao(); // Initialize properly
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Debugging print removed
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String nume = request.getParameter("nume");
        
        if (!NameValidator.validateName(nume)) {
            response.sendRedirect("adddep.jsp?n=true");
            return;
        }
        
        try {
            depDao.addDep(nume); // Ensure this method exists and works in DepDao
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la adaugarea departamentului - motive necunoscute!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
        }
    }
}