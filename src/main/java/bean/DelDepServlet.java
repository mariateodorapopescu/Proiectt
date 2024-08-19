package bean;
// importare biblioteci
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Servlet ce se ocupa de stergerea unui departament
 */
public class DelDepServlet extends HttpServlet {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// dao pentru comunicarea cu baza de date
    private StergereDepartamentDAO employeeDao;

    /**
     * initializare DAO
     */
    public void init() throws ServletException {
        try {
            employeeDao = new StergereDepartamentDAO();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DelUsrDao", e);
        }
    }
    
    /**
     * pentru cazul in care se face actiune GET
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { 
    	doPost(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String departament = request.getParameter("username");
        if (departament == null) {
        	// daca nu a primit de la form departamentul
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu e nimeni logat?!');");
 		    out.println("window.location.href = 'modifdeldep.jsp';");
 		    out.println("</script>");
 		    out.close();
        }
        int id = fetchId(departament);
        try {
            employeeDao.stergere(departament, id);
            // trimit notificare la angajati

            // trimiterea de mailuri se face in mod asincron
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            asyncContext.setTimeout(1000);  
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                   MailAsincron.send5(departament);
                    asyncContext.complete();  // Completarea actiunii asincrone
                } catch (Exception e) {
                    e.printStackTrace();  // in caz de eroare, afisez in concola serverului sa vad de ce + redirectare la pagina de adaugare/modificare concediu + alerta
                    asyncContext.complete();  // Context asincron finalizat indiferent de situatie
                    response.setContentType("text/html;charset=UTF-8");
        	        PrintWriter out = null;
					try {
						out = response.getWriter();
					} catch (IOException e1) {
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
            // + sa vada ca departamanetul nu mai exista printre departamentele existente
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	// in caz de eroare redirectionez la aceeasi pagina, ca sa poata vedea toate departamentele existente, dar cu alerta diefrita
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge departamentul din motive necunoscute.');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    
    /**
     * Functie ce afla id-ul unui departament in functie de numele acestuia. departamentele au nume unic
     * @param departament
     * @return id departament cautat
     */
    public int fetchId(String departament) {
    	// declarare si initializare variabile
        int id = -1;
        try {
        	// creare conexiune cu baza de date
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id_dep FROM departament WHERE nume_dep = ?")) {
                preparedStatement.setString(1, departament);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                    	// extragere id
                        id = rs.getInt("id_dep");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return id;
    }    
}
