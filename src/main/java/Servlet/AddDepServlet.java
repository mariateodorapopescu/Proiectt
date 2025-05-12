package Servlet;

// importare librarii
import DAO.*;
import mail.*;
import services.NameValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * servlet ce se ocupa cu adaugarea unui departament
 */
// @WebServlet(asyncSupported = true)
public class AddDepServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private DepDao depDao; 
    
/**
 * initializare DAO
 */
    public void init() {
    	
        depDao = new DepDao(); 
    }
    
    /**
     * pentru cazul in care se face un doGet... server-ul ar trebui sa accepte numai doPost
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    	response.getWriter().append("Nu se poate face get =(");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String nume = request.getParameter("nume"); // adaug numai numele, id-ul este autoincremental
        
        if (!NameValidator.validateName(nume)) {
        	// functie care verifica daca exita numai literali in nume (si cratima sau spartiu)
            response.sendRedirect("adddep.jsp?n=true");
            return;
        }
        
        try {
        	// adaugare
            depDao.addDep(nume);
            
            // apoi redirectionez la pagina care listeaza si permite modificarea si stergerea departamentelor
            // acest lucru il fac pentru ca utilizatorul sa poata vedea ce departamente sunt la un moment dat in institutie 
            // + sa vada ca departamanetul adaugat se afla printre departamentele existente
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
		    // trimiterea de mailuri se face in mod asincron
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send3();
                    asyncContext.complete();  // Completarea actiunii asincrone
                } catch (Exception e) {
                    e.printStackTrace();  // in caz de eroare, afisez in concola serverului sa vad de ce + redirectare la pagina de adaugare/modificare concediu + alerta
                    asyncContext.complete();  // Context asincron finalizat indiferent de situatie
                    response.setContentType("text/html;charset=UTF-8");
        	        PrintWriter out2 = null;
					try {
						out2 = response.getWriter();
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
        	        out2.println("<script type='text/javascript'>");
        	        out2.println("alert('Eroare din cauze necunoscute!');");
        	        out2.println("window.location.href = 'actiuni.jsp';");
        	        out2.println("</script>");
        	        out2.close();
        	        return;    
                }
            });
        } catch (Exception e) {
        	// in caz de eroare redirectionez la aceeasi pagina, ca sa poata vedea toate departamentele existente, dar cu alerta diefrita
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la adaugarea departamentului - motive necunoscute!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        }
    }
}