package Servlet;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UpdateTaskStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        String status = request.getParameter("status");
        
        if (id == null || status == null || id.isEmpty() || status.isEmpty()) {
            response.sendRedirect("administrare_taskuri.jsp?action=list&error=parametri_lipsa");
            return;
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Actualizăm doar statusul
                String sql = "UPDATE tasks SET status = ? WHERE id = ?";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setString(1, status);
                    pstmt.setString(2, id);
                    
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Adăugare notificare pentru supervizor
                        String sqlNotification = "INSERT INTO notificari_task (id_task, id_ang, tip_notificare, mesaj) " +
                                                "SELECT ?, supervizor, 'STATUS_SCHIMBAT', CONCAT('Statusul task-ului \"', nume, '\" a fost modificat') " +
                                                "FROM tasks WHERE id = ?";
                        try (PreparedStatement pstmtNotif = connection.prepareStatement(sqlNotification)) {
                            pstmtNotif.setString(1, id);
                            pstmtNotif.setString(2, id);
                            pstmtNotif.executeUpdate();
                        } catch (Exception e) {
                            // Ignorăm erorile de notificare
                            e.printStackTrace();
                        }
                        
                        response.sendRedirect("administrare_taskuri.jsp?action=list&success=true");
                    } else {
                        response.sendRedirect("administrare_taskuri.jsp?action=status&id=" + id + "&error=true");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_taskuri.jsp?action=status&id=" + id + "&error=" + e.getMessage());
        }
    }
}