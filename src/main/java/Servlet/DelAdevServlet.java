package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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

import bean.MyUser;

/**
 * Servlet implementation class DelAdevServlet
 */
public class DelAdevServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DelAdevServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

    /**
     * Metoda GET - procesarea cererii de ștergere a adeverinței
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verificare sesiune
        HttpSession sesiune = request.getSession(false);
        if (sesiune == null) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Nu există sesiune activă!');");
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
            out.println("alert('Utilizator neconectat!');");
            out.println("window.location.href = 'login.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        // Extragere parametru idadev
        int idAdeverinta;
        try {
            idAdeverinta = Integer.parseInt(request.getParameter("idadev"));
        } catch (NumberFormatException e) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('ID adeverință invalid!');");
            out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
            out.println("</script>");
            out.close();
            return;
        }
        
        // Verificare permisiuni
        Connection conn = null;
        PreparedStatement verificareStmt = null;
        PreparedStatement stergereStmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false); // Începem o tranzacție
            
            // Verificare existență adeverință și permisiune de ștergere
            String sqlVerificare = "SELECT a.id_ang, a.status, u.tip FROM adeverinte a JOIN useri u ON a.id_ang = u.id WHERE a.id = ?";
            verificareStmt = conn.prepareStatement(sqlVerificare);
            verificareStmt.setInt(1, idAdeverinta);
            
            ResultSet rs = verificareStmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința nu există!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
                return;
            }
            
            int idAngajat = rs.getInt("id_ang");
            int status = rs.getInt("status");
            int tipAngajat = rs.getInt("tip");
            
            int currentUserId = currentUser.getId();
            int userType = currentUser.getTip();
            
            // Verificare dacă utilizatorul are dreptul să șteargă adeverința
            boolean hasPermission = false;
            
            // Utilizatorul poate șterge adeverințele proprii doar dacă sunt în status 0 (neaprobate)
            if (idAngajat == currentUserId && status == 0) {
                hasPermission = true;
            }
            
            // Șeful (tip=3) poate șterge adeverințele angajaților din departamentul său
            if (userType == 3 && status <= 1) {
                // Verificăm dacă angajatul este în același departament
                String sqlDep = "SELECT 1 FROM useri WHERE id = ? AND id_dep = (SELECT id_dep FROM useri WHERE id = ?)";
                try (PreparedStatement depStmt = conn.prepareStatement(sqlDep)) {
                    depStmt.setInt(1, idAngajat);
                    depStmt.setInt(2, currentUserId);
                    ResultSet rsDep = depStmt.executeQuery();
                    if (rsDep.next()) {
                        hasPermission = true;
                    }
                }
            }
            
            // Directorul (tip=0) poate șterge orice adeverință
            if (userType == 0) {
                hasPermission = true;
            }
            
            if (!hasPermission) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Nu aveți permisiunea de a șterge această adeverință!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
                return;
            }
            
            // Ștergerea adeverinței
            String sqlStergere = "DELETE FROM adeverinte WHERE id = ?";
            stergereStmt = conn.prepareStatement(sqlStergere);
            stergereStmt.setInt(1, idAdeverinta);
            
            int rezultat = stergereStmt.executeUpdate();
            
            if (rezultat > 0) {
                conn.commit(); // Confirmăm tranzacția
                
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința a fost ștearsă cu succes!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
            } else {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Nu s-a putut șterge adeverința!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
            }
            
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la ștergerea adeverinței: " + e.getMessage() + "');");
            out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
            out.println("</script>");
            out.close();
        } finally {
            try {
                if (verificareStmt != null) verificareStmt.close();
                if (stergereStmt != null) stergereStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Resetăm autocommit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Metoda POST - redirecționată către GET
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}