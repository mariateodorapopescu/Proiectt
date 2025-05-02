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

public class AdaugaPostServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//        Integer userDep = (Integer) session.getAttribute("userDep");
//        
//        // Verificare permisiuni
//        if (userTip == null || (userTip != 0 && (userTip != 3 && userDep != 1))) {
//            response.sendRedirect("Access.jsp?error=accessDenied");
//            return;
//        }
        
        // Obținerea parametrilor postului
        String titlu = request.getParameter("titlu");
        String req = request.getParameter("req");
        String resp = request.getParameter("resp");
        String dom = request.getParameter("dom");
        String subdom = request.getParameter("subdom");
        int pozitie = Integer.parseInt(request.getParameter("pozitie"));
        int departament = Integer.parseInt(request.getParameter("departament"));
        Date start = Date.valueOf(request.getParameter("start"));
        Date end = Date.valueOf(request.getParameter("end"));
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
            
//            // 1. Mai întâi inserăm locația nouă
//            String sqlLoc = "INSERT INTO locatii_joburi (strada, oras, judet, tara) VALUES (?, ?, ?, 'România')";
//            PreparedStatement pstmtLoc = conn.prepareStatement(sqlLoc, Statement.RETURN_GENERATED_KEYS);
//            pstmtLoc.setString(1, strada);
//            pstmtLoc.setString(2, localitate);
//            pstmtLoc.setString(3, judet);
//           
//            pstmtLoc.executeUpdate();
//            
//            // Obținem ID-ul generat pentru locație
//            int idLocatie = 0;
//            ResultSet generatedKeys = pstmtLoc.getGeneratedKeys();
//            if (generatedKeys.next()) {
//                idLocatie = generatedKeys.getInt(1);
//            } else {
//                throw new SQLException("Eroare la crearea locației, nu s-a obținut ID-ul.");
//            }
//            pstmtLoc.close();
//            
//            // 2. Apoi inserăm postul
            String sql = "INSERT INTO joburi (titlu, req, resp, dom, subdom, pozitie, departament, " +
                        "start, end, activ, keywords, ore, tip) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)";
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
            //pstmt.setInt(10, idLocatie);
            pstmt.setString(10, keywords);
            pstmt.setInt(11, ore);
            pstmt.setBoolean(12, tip);
            
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
            response.sendRedirect("administrare_posturi.jsp?action=add&error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_posturi.jsp?action=add&error=true");
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