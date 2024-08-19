package bean;

//importare biblioteci
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Servlet ce se ocupa cu aprobarea unui concediu
 */
public class AprobDirServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// DAO pentru baza de date
    private AprobDirDao dep;
    
/**
 * initializare DAO
 */
    public void init() {
        dep = new AprobDirDao();
    }
    
    /**
     * teoretic nu poate afce doGet, practic eu cand aprob fac o cerere get si dau sa o procesez ca pe un post 
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doPost(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sesiune = request.getSession(false); 
        // o verificare in plus, la un debug, asta ca sa ma asigur ca extrag ceva valid si nu am erori dupa
        if (sesiune == null) {
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Sesiune nula!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }
        
        MyUser currentUser = (MyUser) sesiune.getAttribute("currentUser");
        if (currentUser == null) {
        	response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu e conectat niciun utilizator!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }

        int idconcediu = Integer.parseInt(request.getParameter("idcon"));

        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            dep.modif(idconcediu); // fac aprobarea in DAO, aprobare = schimbare status
            
           // notificare asincrona
	    	    
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Aprobare cu succes!');");
		    out.println("window.location.href = 'vizualizareconcedii.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (SQLException e) {
            printSQLException(e);
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare la baza de date!');");
		    out.println("window.location.href = 'concediinoidir.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
        	e.printStackTrace();
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare - nu s-a gasit clasa, debug only!');");
		    out.println("window.location.href = 'concediinoidir.jsp';");
		    out.println("</script>");
		    out.close();
		}
    }

    private static void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                System.err.println("SQLState: " + ((SQLException) e).getSQLState());
                System.err.println("Error Code: " + ((SQLException) e).getErrorCode());
                System.err.println("Message: " + e.getMessage());
                Throwable t = ex.getCause();
                while (t != null) {
                    System.out.println("Cause: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}
