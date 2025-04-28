package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import bean.MyUser;

public class CerereDemisieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userId = currentUser.getId();
        
        // Validare parametri
        String motiv = request.getParameter("motiv");
        Date dataUltimaZi;
        try {
            dataUltimaZi = Date.valueOf(request.getParameter("data_ultima_zi"));
            
            // Verificare dacă data ultimei zile este în viitor
            if (dataUltimaZi.before(new Date(System.currentTimeMillis()))) {
                response.sendRedirect("cerere_demisie.jsp?error=invalidDate");
                return;
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect("cerere_demisie.jsp?error=invalidDate");
            return;
        }
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            // Verificăm dacă tabela cereri_demisie există
            boolean tabelaExista = false;
            try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'cereri_demisie'");
                 ResultSet rsCheck = checkStmt.executeQuery()) {
                tabelaExista = rsCheck.next();
            }
            
            // Dacă tabela nu există, o creăm
            if (!tabelaExista) {
                try (PreparedStatement createStmt = conn.prepareStatement(
                        "CREATE TABLE cereri_demisie (" +
                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "id_ang INT NOT NULL, " +
                        "motiv VARCHAR(500), " +
                        "data_cerere DATE NOT NULL, " +
                        "data_ultima_zi DATE NOT NULL, " +
                        "status VARCHAR(20) NOT NULL, " +
                        "data_procesare DATE, " +
                        "observatii VARCHAR(500), " +
                        "FOREIGN KEY (id_ang) REFERENCES useri(id))")) {
                    createStmt.executeUpdate();
                }
            }
            
            // Verificăm dacă utilizatorul are deja o cerere de demisie activă
            try (PreparedStatement checkDemisieStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM cereri_demisie WHERE id_ang = ? AND status = 'IN_ASTEPTARE'")) {
                checkDemisieStmt.setInt(1, userId);
                try (ResultSet rs = checkDemisieStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect("cerere_demisie.jsp?error=existingRequest");
                        return;
                    }
                }
            }
            
            // Înregistrează cererea de demisie
            try (PreparedStatement pstmt = conn.prepareStatement(
                    "INSERT INTO cereri_demisie (id_ang, motiv, data_cerere, data_ultima_zi, status) " +
                    "VALUES (?, ?, CURDATE(), ?, 'IN_ASTEPTARE')")) {
                pstmt.setInt(1, userId);
                pstmt.setString(2, motiv);
                pstmt.setDate(3, dataUltimaZi);
                pstmt.executeUpdate();
            }
            
            // Notifică șeful de departament și HR
            notificaSefSiHR(conn, userId);
            
            conn.commit();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Cerere trimisa cu succes!');");
		    out.println("window.location.href = 'actiuni2.jsp';");
		    out.println("</script>");
		    out.close();
            return;
            
        } catch (SQLException | ClassNotFoundException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect("cerere_demisie.jsp?error=database&message=" + e.getMessage());
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { 
                    e.printStackTrace(); 
                }
            }
        }
    }
    
    private void notificaSefSiHR(Connection conn, int idAngajat) throws SQLException {
        // Verificăm dacă tabela notificari_general există
        boolean tabelaExista = false;
        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'notificari_general'");
             ResultSet rsCheck = checkStmt.executeQuery()) {
            tabelaExista = rsCheck.next();
        }
        
        // Dacă tabela nu există, o creăm
        if (!tabelaExista) {
            try (PreparedStatement createStmt = conn.prepareStatement(
                    "CREATE TABLE notificari_general (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "id_destinatar INT NOT NULL, " +
                    "tip VARCHAR(50) NOT NULL, " +
                    "mesaj VARCHAR(255) NOT NULL, " +
                    "data_creare TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "citit BOOLEAN DEFAULT FALSE, " +
                    "FOREIGN KEY (id_destinatar) REFERENCES useri(id))")) {
                createStmt.executeUpdate();
            }
        }
        
        // Obținem numele și prenumele angajatului pentru a personaliza mesajul
        String numeAngajat = "Un angajat";
        try (PreparedStatement getUserStmt = conn.prepareStatement("SELECT nume, prenume FROM useri WHERE id = ?")) {
            getUserStmt.setInt(1, idAngajat);
            try (ResultSet rs = getUserStmt.executeQuery()) {
                if (rs.next()) {
                    numeAngajat = rs.getString("nume") + " " + rs.getString("prenume");
                }
            }
        }
        
        // Notifică șeful de departament
        try (PreparedStatement pstmt = conn.prepareStatement(
                "SELECT u2.id FROM useri u1 " +
                "JOIN useri u2 ON u1.id_dep = u2.id_dep " +
                "WHERE u1.id = ? AND u2.tip = 3")) {
            pstmt.setInt(1, idAngajat);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int idSef = rs.getInt("id");
                    
                    try (PreparedStatement insertStmt = conn.prepareStatement(
                            "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                            "VALUES (?, 'CERERE_DEMISIE', ?)")) {
                        insertStmt.setInt(1, idSef);
                        insertStmt.setString(2, numeAngajat + " a depus cerere de demisie.");
                        insertStmt.executeUpdate();
                    }
                }
            }
        }
        
        // Notifică HR
        try (PreparedStatement pstmt = conn.prepareStatement(
                "SELECT id FROM useri WHERE tip = 3 AND id_dep = 1")) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int idHR = rs.getInt("id");
                    
                    try (PreparedStatement insertStmt = conn.prepareStatement(
                            "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                            "VALUES (?, 'CERERE_DEMISIE', ?)")) {
                        insertStmt.setInt(1, idHR);
                        insertStmt.setString(2, numeAngajat + " a depus cerere de demisie.");
                        insertStmt.executeUpdate();
                    }
                }
            }
        }
    }
}