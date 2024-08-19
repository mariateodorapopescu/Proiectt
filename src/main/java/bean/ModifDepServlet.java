package bean;
// importare biblioteci
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
/**
 * Servlet ce se ocupa cu modificarea [numelui] unui departament
 */
public class ModifDepServlet extends HttpServlet {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// un DAO pentru a incarca obiectul cu modificarile
    private ModifDepDao dep;
    
    /**
     * initializeaza DAO
     */
    public void init() {
        dep = new ModifDepDao();
    }
    
	/**
	 * acest servlet face numai POST
	 */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String departament = request.getParameter("username");
        String old = request.getParameter("password");
        
        if (departament == null) {
        	response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu s-a incarcat departamentul!');");
 		    out.println("window.location.href = 'modifdeldep.jsp';");
 		    out.println("</script>");
 		    out.close();
            return;
        }
        
        // functie care verifica daca exita numai literali in nume (si cratima sau spartiu)
        if (!NameValidator.validateName(departament)) {
            response.sendRedirect("modifdep2.jsp?n=true");
            return;
        }

        try {
            dep.modif(departament, old);
            
            // trimiterea de mailuri se face in mod asincron
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            asyncContext.setTimeout(10000);  
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send4(old, departament);
                    asyncContext.complete();  // Completarea actiunii asincrone
                } catch (Exception e) {
                    e.printStackTrace();  // in caz de eroare, afisez in concola serverului sa vad de ce + redirectare la pagina de adaugare/modificare concediu + alerta
                    asyncContext.complete();  // Context asincron finalizat indiferent de situatie
                    response.setContentType("text/html;charset=UTF-8");
        	        PrintWriter out = null;
					try {
						out = response.getWriter();
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
        	        out.println("<script type='text/javascript'>");
        	        out.println("alert('Eroare din cauze necunoscute!');");
        	        out.println("window.location.href = 'actiuni.jsp';");
        	        out.println("</script>");
        	        out.close();
        	        return; 
                    
                }
            });
            
            // apoi redirectionez la pagina care listeaza si permite modificarea si stergerea departamentelor
            // acest lucru il fac pentru ca utilizatorul sa poata vedea ce departamente sunt la un moment dat in institutie 
            // + sa vada ca departamanetul modificat se afla printre departamentele existente
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	// in caz de eroare redirectionez la aceeasi pagina, ca sa poata vedea toate departamentele existente, dar cu alerta diefrita
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
}
