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

public class AdaugaTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String nume = request.getParameter("nume");
        String descriere = request.getParameter("descriere");
        String idPrj = request.getParameter("id_prj");
        String idAng = request.getParameter("id_ang");
        String supervizor = request.getParameter("supervizor");
        String start = request.getParameter("start");
        String end = request.getParameter("end");
        String status = request.getParameter("status");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Generare ID task unic
                int newTaskId = 1;
                String sqlMaxId = "SELECT MAX(id) as max_id FROM tasks";
                try (PreparedStatement stmt = connection.prepareStatement(sqlMaxId)) {
                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        newTaskId = rs.getInt("max_id") + 1;
                    }
                }
                
                // Inserarea noului task
                String sql = "INSERT INTO tasks (id, nume, id_prj, id_ang, supervizor, start, end, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setInt(1, newTaskId);
                    pstmt.setString(2, nume);
                    pstmt.setString(3, idPrj);
                    pstmt.setString(4, idAng);
                    pstmt.setString(5, supervizor);
                    pstmt.setString(6, start);
                    pstmt.setString(7, end);
                    pstmt.setString(8, status);
                    
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Creare notificare pentru persoana asignată
                        if (!idAng.equals(supervizor)) {
                            String sqlNotification = "INSERT INTO notificari_task (id_task, id_ang, tip_notificare, mesaj) VALUES (?, ?, ?, ?)";
                            try (PreparedStatement pstmtNotif = connection.prepareStatement(sqlNotification)) {
                                pstmtNotif.setInt(1, newTaskId);
                                pstmtNotif.setString(2, idAng);
                                pstmtNotif.setString(3, "TASK_NOU");
                                pstmtNotif.setString(4, "Ați primit un task nou: " + nume);
                                pstmtNotif.executeUpdate();
                            } catch (SQLException e) {
                                // Ignoră eroarea de notificare - continua fluxul
                                e.printStackTrace();
                            }
                        }
                        
                        response.sendRedirect("administrare_taskuri.jsp?action=list&success=true");
                    } else {
                        response.sendRedirect("administrare_taskuri.jsp?action=add&error=true");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_taskuri.jsp?action=add&error=" + e.getMessage());
        }
    }
}