package Servlet;

import mail.*;
import bean.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import DAO.AprobDirDao;

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
        
        MyUser utilizatorcurent = (MyUser) sesiune.getAttribute("currentUser");
        if (utilizatorcurent == null) {
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
        String motiv = request.getParameter("reason");
        //System.out.println(motiv);
            int id = -1;
    
        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            dep.aprobare(idconcediu, motiv); // fac aprobarea in DAO, aprobare = schimbare status
            id = getIdAng(idconcediu, conexiune);
            final int id2 = id; 
           // notificare asincrona
            new Thread(() -> {
                try {
                    MailAsincron.send6(id2, idconcediu);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();
            
            // apoi redirectionez la pagina care listeaza concediile
            // acest lucru il fac pentru ca utilizatorul sa poata vedea ce concedii sunt la un moment dat in institutie 
            // + sa vada ca s-a aprobat cu succes   
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Aprobare cu succes!');");
		    out.println("window.location.href = 'concediinoisef.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (SQLException e) {
        	// in caz de eroare redirectionez la aceeasi pagina, ca sa poata vedea ca nu s-a aprobat
            printSQLException(e);
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare la baza de date!');");
		    out.println("window.location.href = 'concediinoisef.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (ClassNotFoundException e) {
        	// in caz de eroare redirectionez la aceeasi pagina, ca sa poata vedea ca nu s-a aprobat
        	e.printStackTrace();
        	response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare - nu s-a gasit clasa, debug only!');");
		    out.println("window.location.href = 'concediinoisef.jsp';");
		    out.println("</script>");
		    out.close();
		}
    }

    /**
     * Functie ce afla id-ul unui angajat dintr-un concediu
     * @param idconcediu
     * @param conexiune
     * @return id angajat sau -1 daca nu a gasit nimic
     * @throws SQLException
     */
    private int getIdAng(int idconcediu, Connection conexiune) throws SQLException {
        String sql = "SELECT id_ang FROM concedii WHERE id = ?";
        try (PreparedStatement stmt = conexiune.prepareStatement(sql)) {
            stmt.setInt(1, idconcediu);
            ResultSet rezultat = stmt.executeQuery();
            if (rezultat.next()) {
                return rezultat.getInt("id_ang");
            }
        }
        return -1; 
    }
    
    /**
	 * Afiseaza frumos / Pretty print o eroare dintr-o baza de date
	 * @param ex
	 */
	private static void printSQLException(SQLException ex) {
        for (Throwable e: ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                System.err.println("Stare: " + ((SQLException) e).getSQLState());
                System.err.println("Cod eroare: " + ((SQLException) e).getErrorCode());
                System.err.println("Explicatie: " + e.getMessage());
                Throwable t = ex.getCause();
                while (t != null) {
                    System.out.println("Cauza: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}
