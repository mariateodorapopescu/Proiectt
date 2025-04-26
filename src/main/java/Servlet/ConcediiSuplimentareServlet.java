package Servlet;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ConcediiSuplimentareServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        
        Connection conn = null;
        try {
            // Încărcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directă
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            // Criterii pentru zile suplimentare de concediu
            String[] sqlCriteria = {
                // Productivitate 50% în ultimul trimestru
                "SELECT u.id, 5 as zile_extra FROM useri u " +
                "WHERE u.activ = 1 AND " +
                "(SELECT AVG(procent) FROM tasks t JOIN statusuri2 s ON t.status = s.id " +
                "WHERE t.id_ang = u.id AND t.end >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) >= 50",
                
                // 5 activități în ultimul an
                "SELECT u.id, 3 as zile_extra FROM useri u " +
                "WHERE u.activ = 1 AND " +
                "(SELECT COUNT(*) FROM tasks t WHERE t.id_ang = u.id " +
                "AND t.end >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)) >= 5",
                
                // Prezență 100% în ultimul trimestru
                "SELECT u.id, 2 as zile_extra FROM useri u " +
                "WHERE u.activ = 1 AND " +
                "(SELECT COUNT(*) FROM concedii c WHERE c.id_ang = u.id " +
                "AND c.start_c >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND c.status = 2) = 0"
            };
            
            for (String sql : sqlCriteria) {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                
                while (rs.next()) {
                    int idAng = rs.getInt("id");
                    int zileExtra = rs.getInt("zile_extra");
                    
                    // Adaugă zile suplimentare
                    String updateSql = "UPDATE useri SET zileramase = zileramase + ? WHERE id = ?";
                    PreparedStatement updatePstmt = conn.prepareStatement(updateSql);
                    updatePstmt.setInt(1, zileExtra);
                    updatePstmt.setInt(2, idAng);
                    updatePstmt.executeUpdate();
                    updatePstmt.close();
                    
                    // Înregistrează în istoric
                    String historicSql = "INSERT INTO istoric_concedii_suplimentare " +
                                       "(id_ang, zile_acordate, motiv, data_acordare) VALUES (?, ?, ?, CURDATE())";
                    PreparedStatement historicPstmt = conn.prepareStatement(historicSql);
                    historicPstmt.setInt(1, idAng);
                    historicPstmt.setInt(2, zileExtra);
                    historicPstmt.setString(3, "Criterii performanță îndeplinite");
                    historicPstmt.executeUpdate();
                    historicPstmt.close();
                }
                
                rs.close();
                pstmt.close();
            }
            
            conn.commit();
            response.sendRedirect("concedii_suplimentare.jsp?success=true");
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("concedii_suplimentare.jsp?error=driverError");
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect("concedii_suplimentare.jsp?error=true");
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}