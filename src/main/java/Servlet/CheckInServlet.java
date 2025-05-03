package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalTime;
import org.json.JSONObject;

public class CheckInServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            json.put("success", false);
            json.put("message", "Utilizator neautentificat");
            out.print(json.toString());
            return;
        }
        
        String comentariu = request.getParameter("comentariu");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "INSERT INTO prezenta (id_ang, data, ora, comentariu) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setDate(2, java.sql.Date.valueOf(LocalDate.now()));
            pstmt.setTime(3, java.sql.Time.valueOf(LocalTime.now()));
            pstmt.setString(4, comentariu);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            json.put("success", true);
            
            // Trimite notificare către HR dacă este o întârziere
            if (LocalTime.now().isAfter(LocalTime.of(9, 0))) {
                notificaHRIntarziere(conn, userId, comentariu);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la înregistrarea prezenței");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la încărcarea driver-ului JDBC");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
    
    private void notificaHRIntarziere(Connection conn, int userId, String comentariu) 
            throws SQLException {
        // Găsește toți utilizatorii HR
        String sql = "SELECT id FROM useri WHERE tip = 3 AND id_dep = 1";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        while (rs.next()) {
            // Trimite notificare către fiecare HR
            String notificareSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                                  "VALUES (?, 'INTARZIERE', ?)";
            PreparedStatement nPstmt = conn.prepareStatement(notificareSql);
            nPstmt.setInt(1, rs.getInt("id"));
            nPstmt.setString(2, "Angajatul cu ID " + userId + " a întârziat. " +
                            (comentariu != null ? "Motiv: " + comentariu : ""));
            nPstmt.executeUpdate();
            nPstmt.close();
        }
        
        rs.close();
        pstmt.close();
    }
}