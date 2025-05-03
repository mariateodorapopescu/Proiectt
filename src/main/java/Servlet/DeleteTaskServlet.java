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

import org.json.JSONObject;

import bean.MyUser;

public class DeleteTaskServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        // Preluăm parametrul
        int idTask = Integer.parseInt(request.getParameter("id"));
        
        // Preluăm datele utilizatorului din sesiune
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            json.put("success", false);
            json.put("message", "Utilizator neautentificat!");
            out.print(json.toString());
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userId = currentUser.getId();
        int userTip = currentUser.getTip();
        
        Connection conn = null;
        try {
            // Încarcăm driver-ul JDBC
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Stabilim conexiunea cu DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            // Verificăm dacă utilizatorul are dreptul de a șterge
            String checkSql = "SELECT supervizor FROM tasks WHERE id = ?";
            try (PreparedStatement checkPstmt = conn.prepareStatement(checkSql)) {
                checkPstmt.setInt(1, idTask);
                try (ResultSet rs = checkPstmt.executeQuery()) {
                    if (rs.next()) {
                        int supervizorId = rs.getInt("supervizor");
                        // doar director (tip 0) sau supervizor pot șterge
                        if (userTip != 0 && supervizorId != userId) {
                            json.put("success", false);
                            json.put("message", "Doar supervizorul sau directorul poate șterge acest task!");
                            out.print(json.toString());
                            return;
                        }
                    } else {
                        json.put("success", false);
                        json.put("message", "Task inexistent!");
                        out.print(json.toString());
                        return;
                    }
                }
            }

            // Ștergem task-ul
            String sql = "DELETE FROM tasks WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idTask);
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    json.put("success", true);
                    json.put("message", "Task-ul a fost șters cu succes!");
                } else {
                    json.put("success", false);
                    json.put("message", "Task-ul nu a fost găsit!");
                }
            }
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Driver JDBC neidentificat!");
        } catch (SQLException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la baza de date: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
}
