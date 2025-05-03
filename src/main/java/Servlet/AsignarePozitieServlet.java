package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;

public class AsignarePozitieServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//        Integer userDep = (Integer) session.getAttribute("userDep");
//        
//        // Verificare permisiuni - doar Admin HR
//        if (userTip == null || (userTip != 3 && userDep != 1)) {
//            response.sendRedirect("Access.jsp?error=accessDenied");
//            return;
//        }
        
        int idAng = Integer.parseInt(request.getParameter("id_ang"));
        int idDep = Integer.parseInt(request.getParameter("id_dep"));
        int tipPozitie = Integer.parseInt(request.getParameter("tip_pozitie"));
        Date dataPozitie = Date.valueOf(request.getParameter("data_pozitie"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);
            
            // Obține tipul vechi și departamentul vechi pentru istoric
            String getTipAndDep = "SELECT tip, id_dep FROM useri WHERE id = ?";
            PreparedStatement pstmtGet = conn.prepareStatement(getTipAndDep);
            pstmtGet.setInt(1, idAng);
            ResultSet rs = pstmtGet.executeQuery();
            
            int tipVechi = 0;
            int depVechi = 0;
            if (rs.next()) {
                tipVechi = rs.getInt("tip");
                depVechi = rs.getInt("id_dep");
            }
            
            // Actualizează angajatul
            String sql = "UPDATE useri SET id_dep = ?, tip = ?, data_modif = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idDep);
            pstmt.setInt(2, tipPozitie);
            pstmt.setDate(3, dataPozitie);
            pstmt.setInt(4, idAng);
            pstmt.executeUpdate();
            
            // Înregistrează în istoric_promovari
            String tipPromovare = (depVechi == idDep) ? "Promovare internă" : "Transfer departament";
            sql = "INSERT INTO istoric_promovari (id_ang, tip_vechi, tip_nou, tip_promovare, data_promovare) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idAng);
            pstmt.setInt(2, tipVechi);
            pstmt.setInt(3, tipPozitie);
            pstmt.setString(4, tipPromovare);
            pstmt.setDate(5, dataPozitie);
            pstmt.executeUpdate();
            
            conn.commit();
            response.sendRedirect("administrare_pozitii.jsp?success=true");
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect("administrare_pozitii.jsp?error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_pozitii.jsp?error=driverNotFound");
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
}