package Servlet;
// importare biblioteci
import DAO.*;
import bean.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mail.MailAsincron;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Implementarea servlet-ului ce se ocupa de stergerea unui concediu
 */
public class DelConServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DelConServlet() {
        super();
    }
    // DAO pentru baza de date
    private DelConDao concediu;
    /**
     * initializare DAO
     */
    public void init() {
        concediu = new DelConDao();
    }
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	// declarare si initializare variabile
		int id = Integer.valueOf(request.getParameter("idcon"));
		String inceput = request.getParameter("start");
		String sfarsit = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");
    	
        Concediu concediul = new Concediu();
        
        // setare date de clasa a obiectului concediu
        concediul.setId(id);
        concediul.setInceput(inceput);
        concediul.setSfarsit(sfarsit);
        concediul.setMotiv(motiv);
        concediul.setLocatie(locatie);
        
        try {
            concediu.stergere(concediul);
           
            // trimitere asincrona
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
             
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send9(id);
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
        	        out.println("alert('eroare din cauze necunoscute!');");
        	        out.println("window.location.href = 'actiuni.jsp';");
        	        out.println("</script>");
        	        out.close();
        	        return; 
                    
                }
            });
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge concediul din motive necunoscute.');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}

}
