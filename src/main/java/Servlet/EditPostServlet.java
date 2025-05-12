package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;

public class EditPostServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    
        // Obținerea parametrilor postului
        int idPost = Integer.parseInt(request.getParameter("id"));
        String titlu = request.getParameter("titlu");
        String req = request.getParameter("req");
        String resp = request.getParameter("resp");
        String dom = request.getParameter("dom");
        String subdom = request.getParameter("subdom");
        int pozitie = Integer.parseInt(request.getParameter("pozitie"));
        int departament = Integer.parseInt(request.getParameter("departament"));
        Date start = Date.valueOf(request.getParameter("start"));
        Date end = Date.valueOf(request.getParameter("end"));
        boolean activ = "1".equals(request.getParameter("activ"));
        int ore = Integer.parseInt(request.getParameter("ore"));
        boolean tip = "1".equals(request.getParameter("tip"));
        String keywords = request.getParameter("keywords");
        
        // Obținerea parametrilor de locație
        String judet = request.getParameter("judet");
        String localitate = request.getParameter("localitate");
        String strada = request.getParameter("strada");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Începem o tranzacție pentru a asigura consistența
            conn.setAutoCommit(false);
//            
//            // 1. Mai întâi verificăm ID-ul locației curente a postului
//            String sqlCheckLoc = "SELECT id_locatie FROM joburi WHERE id = ?";
//            PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheckLoc);
//            pstmtCheck.setInt(1, idPost);
//            ResultSet rsCheck = pstmtCheck.executeQuery();
//            
//            int idLocatie = 0;
//            if (rsCheck.next()) {
//                idLocatie = rsCheck.getInt("id_locatie");
//            }
//            rsCheck.close();
//            pstmtCheck.close();
//            
//            // 2. Actualizăm locația existentă sau creăm una nouă
//            if (idLocatie > 0) {
//                // Actualizăm locația existentă
//                String sqlUpdateLoc = "UPDATE locatii_joburi SET strada = ?, oras = ?, judet = ? WHERE id_locatie = ?";
//                PreparedStatement pstmtUpdateLoc = conn.prepareStatement(sqlUpdateLoc);
//                pstmtUpdateLoc.setString(1, strada);
//                pstmtUpdateLoc.setString(2, localitate);
//                pstmtUpdateLoc.setString(3, judet);
//                pstmtUpdateLoc.setInt(4, idLocatie);
//                pstmtUpdateLoc.executeUpdate();
//                pstmtUpdateLoc.close();
//            } else {
//                // Creăm o locație nouă
//                String sqlNewLoc = "INSERT INTO locatii_joburi (strada, oras, judet, tara, cod) VALUES (?, ?, ?, 'România', ?)";
//                PreparedStatement pstmtNewLoc = conn.prepareStatement(sqlNewLoc, Statement.RETURN_GENERATED_KEYS);
//                pstmtNewLoc.setString(1, strada);
//                pstmtNewLoc.setString(2, localitate);
//                pstmtNewLoc.setString(3, judet);
//                pstmtNewLoc.setString(4, ""); // Cod poștal, îl lăsăm gol pentru exemplul acesta
//                pstmtNewLoc.executeUpdate();
//                
//                // Obținem ID-ul generat pentru locație
//                ResultSet generatedKeys = pstmtNewLoc.getGeneratedKeys();
//                if (generatedKeys.next()) {
//                    idLocatie = generatedKeys.getInt(1);
//                } else {
//                    throw new SQLException("Eroare la crearea locației, nu s-a obținut ID-ul.");
//                }
//                pstmtNewLoc.close();
//            }
//            
//            // 3. Actualizăm postul
            String sql = "UPDATE joburi SET titlu = ?, req = ?, resp = ?, dom = ?, subdom = ?, " +
                        "pozitie = ?, departament = ?, start = ?, end = ?, " +
                        "activ = ?, keywords = ?, ore = ?, tip = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, titlu);
            pstmt.setString(2, req);
            pstmt.setString(3, resp);
            pstmt.setString(4, dom);
            pstmt.setString(5, subdom);
            pstmt.setInt(6, pozitie);
            pstmt.setInt(7, departament);
            pstmt.setDate(8, start);
            pstmt.setDate(9, end);
           // pstmt.setInt(10, idLocatie);
            pstmt.setBoolean(10, activ);
            pstmt.setString(11, keywords);
            pstmt.setInt(12, ore);
            pstmt.setBoolean(13, tip);
            pstmt.setInt(14, idPost);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            // Confirmăm tranzacția
            conn.commit();
            
            response.sendRedirect("administrare_posturi.jsp?action=list&success=true");
            
        } catch (SQLException e) {
            // Rollback în caz de eroare
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect("administrare_posturi.jsp?action=edit&id=" + idPost + "&error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_posturi.jsp?action=edit&id=" + idPost + "&error=true");
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