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

public class EditTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        String nume = request.getParameter("nume");
        String idPrj = request.getParameter("id_prj");
        String idAng = request.getParameter("id_ang");
        String supervizor = request.getParameter("supervizor");
        String start = request.getParameter("start");
        String end = request.getParameter("end");
        String status = request.getParameter("status");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Verificarea statusului anterior
                String oldStatus = "";
                String sqlGetOldStatus = "SELECT status, id_ang FROM tasks WHERE id = ?";
                try (PreparedStatement stmt = connection.prepareStatement(sqlGetOldStatus)) {
                    stmt.setString(1, id);
                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        oldStatus = rs.getString("status");
                    }
                }
                
                // Actualizarea task-ului
                String sql = "UPDATE tasks SET nume = ?, id_prj = ?, id_ang = ?, supervizor = ?, start = ?, end = ?, status = ? WHERE id = ?";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setString(1, nume);
                    pstmt.setString(2, idPrj);
                    pstmt.setString(3, idAng);
                    pstmt.setString(4, supervizor);
                    pstmt.setString(5, start);
                    pstmt.setString(6, end);
                    pstmt.setString(7, status);
                    pstmt.setString(8, id);
                    
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Notificare pentru modificarea statusului
                        if (!oldStatus.equals(status)) {
                            String sqlNotification = "INSERT INTO notificari_task (id_task, id_ang, tip_notificare, mesaj) VALUES (?, ?, ?, ?)";
                            try (PreparedStatement pstmtNotif = connection.prepareStatement(sqlNotification)) {
                                pstmtNotif.setString(1, id);
                                pstmtNotif.setString(2, supervizor); // Notifică supervizorul
                                pstmtNotif.setString(3, "STATUS_SCHIMBAT");
                                pstmtNotif.setString(4, "Statusul task-ului \"" + nume + "\" a fost modificat în " + getStatusText(Integer.parseInt(status)));
                                pstmtNotif.executeUpdate();
                            } catch (SQLException e) {
                                // Ignoră eroarea de notificare - continua fluxul
                                e.printStackTrace();
                            }
                        }
                        
                        response.sendRedirect("administrare_taskuri.jsp?action=list&success=true");
                    } else {
                        response.sendRedirect("administrare_taskuri.jsp?action=edit&id=" + id + "&error=true");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_taskuri.jsp?action=edit&id=" + id + "&error=" + e.getMessage());
        }
    }
    
    private String getStatusText(int status) {
        switch (status) {
            case 0: return "0% - Neînceput";
            case 1: return "25% - În lucru";
            case 2: return "50% - La jumătate";
            case 3: return "75% - Aproape gata";
            case 4: return "100% - Finalizat";
            default: return "Necunoscut";
        }
    }
}