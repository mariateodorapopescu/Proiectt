package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.MyUser;

public class CerereAdeverintaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userId = currentUser.getId();
        int tipUser = currentUser.getTip();
        
        // Parametrii cererii
        String tipAdeverintaStr = request.getParameter("tip");
        String pentruServi = request.getParameter("pentru_servi");
        
        if (tipAdeverintaStr == null || tipAdeverintaStr.isEmpty() || pentruServi == null || pentruServi.isEmpty()) {
            response.sendRedirect("cerere_adeverinta.jsp?error=true");
            return;
        }
        
        int tipAdeverinta = Integer.parseInt(tipAdeverintaStr);
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            // Determinăm status-ul inițial bazat pe tipul angajatului
            int initialStatus = 0; // Implicit pentru angajați obișnuiți
            
            // Pentru șefi și manageri (tip == 3 sau 10 <= tip <= 15), statusul inițial este 1 (merge direct la director)
            if (tipUser == 3 || (tipUser >= 10 && tipUser <= 15)) {
                initialStatus = 1;
            }
            
            // Obține un ID nou pentru adeverință
            String getMaxIdSql = "SELECT MAX(id) as max_id FROM adeverinte";
            int newId = 1; // Valoare implicită dacă tabela este goală

            try (PreparedStatement maxIdStmt = conn.prepareStatement(getMaxIdSql);
                ResultSet maxIdRs = maxIdStmt.executeQuery()) {
                if (maxIdRs.next() && maxIdRs.getObject("max_id") != null) {
                    newId = maxIdRs.getInt("max_id") + 1;
                }
            }

            // Inserează adeverința cu ID-ul generat manual
            String sql = "INSERT INTO adeverinte (id, id_ang, tip, pentru_servi, status, creare, modif) " +
                        "VALUES (?, ?, ?, ?, ?, CURDATE(), CURDATE())";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, newId);
                pstmt.setInt(2, userId);
                pstmt.setInt(3, tipAdeverinta);
                pstmt.setString(4, pentruServi);
                pstmt.setInt(5, initialStatus);
                
                int affectedRows = pstmt.executeUpdate();
                
                if (affectedRows > 0) {
                    // Folosim newId în loc de generatedKeys deoarece am furnizat ID-ul manual
                    int idAdeverinta = newId;
                    
                    // Notificăm persoana care trebuie să aprobe cererea
                    if (initialStatus == 0) {
                        // Notificăm șeful departamentului
                        notificaSef(conn, userId, idAdeverinta);
                    } else if (initialStatus == 1) {
                        // Notificăm directorul direct
                        notificaDirector(conn, idAdeverinta);
                    }
                    
                    conn.commit();
                    response.sendRedirect("cerere_adeverinta.jsp?success=true");
                } else {
                    conn.rollback();
                    response.sendRedirect("cerere_adeverinta.jsp?error=true");
                }
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
            response.sendRedirect("cerere_adeverinta.jsp?error=true&message=" + e.getMessage());
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
    
    private void notificaSef(Connection conn, int idAngajat, int idAdeverinta) throws SQLException {
        // Găsim șeful departamentului angajatului
        String sql = "SELECT u.id FROM useri u " +
                    "JOIN useri a ON u.id_dep = a.id_dep " +
                    "WHERE a.id = ? AND u.tip = 3";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idAngajat);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int idSef = rs.getInt("id");
                    
                    // Obține informații despre cerere pentru un mesaj mai descriptiv
                    String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
                    
                    // Verificăm și creăm tabela de notificări dacă nu există
                    createNotificationsTableIfNeeded(conn);
                    
                    // Trimite notificare
                    String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                                     "VALUES (?, 'CERERE_ADEVERINTA', ?)";
                    try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
                        notifPstmt.setInt(1, idSef);
                        notifPstmt.setString(2, "Aveți o nouă cerere de adeverință de aprobat: " + adeverintaInfo);
                        notifPstmt.executeUpdate();
                    }
                }
            }
        }
    }
    
    private void notificaDirector(Connection conn, int idAdeverinta) throws SQLException {
        // Găsim directorul
        String sql = "SELECT id FROM useri WHERE tip = 0";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int idDirector = rs.getInt("id");
                    
                    // Obține informații despre cerere pentru un mesaj mai descriptiv
                    String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
                    
                    // Verificăm și creăm tabela de notificări dacă nu există
                    createNotificationsTableIfNeeded(conn);
                    
                    // Trimite notificare
                    String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                                     "VALUES (?, 'CERERE_ADEVERINTA', ?)";
                    try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
                        notifPstmt.setInt(1, idDirector);
                        notifPstmt.setString(2, "Aveți o nouă cerere de adeverință de aprobat: " + adeverintaInfo);
                        notifPstmt.executeUpdate();
                    }
                }
            }
        }
    }
    
    private String getAdeverintaInfo(Connection conn, int idAdeverinta) throws SQLException {
        // Obține detalii despre adeverință pentru mesaje mai descriptive
        String info = "";
        String sql = "SELECT u.nume, u.prenume, ta.denumire, a.pentru_servi " +
                    "FROM adeverinte a " +
                    "JOIN tip_adev ta ON a.tip = ta.id " +
                    "JOIN useri u ON a.id_ang = u.id " +
                    "WHERE a.id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idAdeverinta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
                    info = numePrenume + " - " + rs.getString("denumire") + " pentru " + rs.getString("pentru_servi");
                }
            }
        }
        
        return info;
    }
    
    private void createNotificationsTableIfNeeded(Connection conn) throws SQLException {
        // Verifică dacă tabela notificari_general există
        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'notificari_general'")) {
            ResultSet rs = checkStmt.executeQuery();
            if (!rs.next()) {
                // Dacă tabela nu există, o creăm
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
        }
    }
}