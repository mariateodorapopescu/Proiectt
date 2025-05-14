package Servlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class DeleteTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        String id = request.getParameter("id");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Șterge notificările asociate
                String sqlDeleteNotifications = "DELETE FROM notificari_task WHERE id_task = ?";
                try (PreparedStatement pstmtNotif = connection.prepareStatement(sqlDeleteNotifications)) {
                    pstmtNotif.setString(1, id);
                    pstmtNotif.executeUpdate();
                }
                
                // Șterge task-ul
                String sql = "DELETE FROM tasks WHERE id = ?";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setString(1, id);
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        jsonResponse.put("success", true);
                        jsonResponse.put("message", "Task-ul a fost șters cu succes!");
                    } else {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Nu s-a putut șterge task-ul!");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Eroare: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
    }
}