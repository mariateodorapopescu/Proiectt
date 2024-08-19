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
 * Clasa ce implementeaza servlet-ul de stergere al unui utilizator
 */
public class DelUsrServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// DAO pentru baza de date
	private DelUsrDao employeeDao;
	
	/**
	 * initializare DAO
	 */
    public void init() throws ServletException {
        try {
            employeeDao = new DelUsrDao();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DeldDao", e);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doPost(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	// declarare si initializare variabile
    	int id = Integer.parseInt(request.getParameter("id"));
    	String numeutilizator = getNumeUtilizatorDinId(id);
        if (numeutilizator == null) {
        	response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu se stie cine sa fie sters');");
 		    out.println("window.location.href = 'modifdel.jsp';");
 		    out.println("</script>");
 		    out.close();
        }

        try {
            employeeDao.deleteUser(numeutilizator, id);
            
            // trimitere asincrona mail-uri
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            asyncContext.setTimeout(1000);
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send10(id, numeutilizator);
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
        	        out.println("alert('eroare din cauze necunoscute!');");
        	        out.println("window.location.href = 'actiuni.jsp';");
        	        out.println("</script>");
        	        out.close();
        	        return; 
                    
                }
            });
            
            response.setContentType("text/html;charset=UTF-8");
            // daca s-a facut stergerea cu succes -> redirectare la pagina in care afiseaza utilizatorii sa vada ca s-a sters
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	// daca nu s-a putut realiza actiunea -> redirectare la pagina in care afiseaza utilizatorii sa vada ca NU s-a sters
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge utilizatorul din motive necunoscute.');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    
    /**
     * Metoda care ajuta la aflarea numelui unui utilizator dupa id
     * @param userId
     * @return nume de utilizator sau "" daca nu a gasit nimic
     */
    private String getNumeUtilizatorDinId(int userId) {
        String numeutilizator = "";
        try {
        	// incarcare driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            // creare conexiune
            try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            		// pregatire interogare
                 PreparedStatement interogare = conexiune.prepareStatement("SELECT username FROM useri WHERE id = ?")) {
                interogare.setInt(1, userId);
                // executare interogare
                try (ResultSet rezultat = interogare.executeQuery()) {
                    if (rezultat.next()) {
                    	// daca s-au intors niste linii, atunci se alege coloana username ca sa extragem datele de care avem nevoie
                        numeutilizator = rezultat.getString("username");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return numeutilizator;
    }
}
