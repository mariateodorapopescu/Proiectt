package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mail.MailAsincron;
import bean.MyUser;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

/**
 * Servlet pentru aprobarea adeverințelor de către șef
 */
public class AprobAdevSef extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * Constructor
     */
    public AprobAdevSef() {
        super();
    }
    
    /**
     * Metoda care procesează cererea de aprobare a adeverinței
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verificare sesiune și utilizator conectat
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
        
        // Verifica dacă utilizatorul are rol de șef
        int userType = currentUser.getTip();
        boolean isSef = userType == 3 || (userType >= 10 && userType <= 15);
        if (!isSef) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Nu aveți permisiunea de a aproba adeverințe ca șef!');");
            out.println("window.location.href = 'adeverintenoiuser.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        // Extrage parametrii
        int idAdeverinta;
        String motivAprobarii = request.getParameter("reason");
        
        try {
            idAdeverinta = Integer.parseInt(request.getParameter("idadev"));
        } catch (NumberFormatException e) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('ID adeverință invalid!');");
            out.println("window.location.href = 'adeverintenoiuser.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        Connection conn = null;
        PreparedStatement verificareStmt = null;
        PreparedStatement updateStmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false); // Incepe tranzacția
            
            // Verifică existența adeverinței și starea ei
            String sqlVerificare = "SELECT a.id_ang, a.status, u.id_dep FROM adeverinte a " +
                                   "JOIN useri u ON a.id_ang = u.id WHERE a.id = ?";
            verificareStmt = conn.prepareStatement(sqlVerificare);
            verificareStmt.setInt(1, idAdeverinta);
            
            ResultSet rs = verificareStmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința nu există!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp';");
                out.println("</script>");
                out.close();
                return;
            }
            
            int status = rs.getInt("status");
            int idAngajat = rs.getInt("id_ang");
            int idDepartament = rs.getInt("id_dep");
            
            // Verifică dacă adeverința este în starea corectă pentru aprobare de șef (status = 0)
            if (status != 0) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința nu este în starea care permite aprobarea de către șef!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp';");
                out.println("</script>");
                out.close();
                return;
            }
            
            // Actualizează starea adeverinței la "Aprobat șef" (status = 1)
            String sqlUpdate = "UPDATE adeverinte SET status = 1, modif = CURDATE(), pentru_servi = ? WHERE id = ?";
            updateStmt = conn.prepareStatement(sqlUpdate);
            updateStmt.setString(1, motivAprobarii);
            updateStmt.setInt(2, idAdeverinta);
            
            int result = updateStmt.executeUpdate();
            
            if (result > 0) {
                conn.commit(); // Confirmă tranzacția
                
                // Trimite notificare prin email
                final int finalIdAngajat = idAngajat;
                final int finalIdAdeverinta = idAdeverinta;
                
                Thread emailThread = new Thread(() -> {
                    try {
                        MailAsincron.trimitereNotificareAdeverintaAprobataSef(finalIdAngajat, finalIdAdeverinta);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                });
                
                emailThread.start();
                
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința a fost aprobată cu succes!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp';");
                out.println("</script>");
                out.close();
            } else {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Nu s-a putut aproba adeverința!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp';");
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
            out.println("alert('Eroare la aprobarea adeverinței: " + e.getMessage() + "');");
            out.println("window.location.href = 'adeverintenoiuser.jsp';");
            out.println("</script>");
            out.close();
        } finally {
            try {
                if (verificareStmt != null) verificareStmt.close();
                if (updateStmt != null) updateStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Resetează autocommit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Metoda doGet redirecționată către doPost
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}