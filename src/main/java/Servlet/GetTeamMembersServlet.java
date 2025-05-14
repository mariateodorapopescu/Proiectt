package Servlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class GetTeamMembersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String projectId = request.getParameter("projectId");
        String userIerarhieStr = request.getParameter("userIerarhie");
        int userIerarhie = 0; // Default ierarhie
        
        if (userIerarhieStr != null && !userIerarhieStr.isEmpty()) {
            try {
                userIerarhie = Integer.parseInt(userIerarhieStr);
            } catch (NumberFormatException e) {
                // Ignorăm eroarea de parsare și folosim valoarea default
            }
        }
        
        if (projectId == null || projectId.isEmpty()) {
            out.println("<option value=''>-- Selectați mai întâi un proiect --</option>");
            return;
        }
        
        Connection connection = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Prima încercăm să obținem membrii echipei bazat pe relația din baza de date și ierarhie
            String sql = 
                "SELECT DISTINCT u.id, u.nume, u.prenume " +
                "FROM useri u " +
                "JOIN membrii_echipe me ON u.id = me.id_ang " +
                "JOIN echipe e ON me.id_echipa = e.id " +
                "JOIN tipuri t ON u.tip = t.tip " +
                "WHERE e.id_prj = ? AND t.ierarhie > ? " + // Doar utilizatori cu ierarhie mai mică
                "ORDER BY u.nume, u.prenume";
            
            stmt = connection.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(projectId));
            stmt.setInt(2, userIerarhie);
            rs = stmt.executeQuery();
            
            boolean foundMembers = false;
            StringBuilder results = new StringBuilder();
            
            while (rs.next()) {
                foundMembers = true;
                results.append("<option value='")
                       .append(rs.getInt("id"))
                       .append("'>")
                       .append(rs.getString("nume"))
                       .append(" ")
                       .append(rs.getString("prenume"))
                       .append("</option>");
            }
            
            if (foundMembers) {
                // Adaugă o opțiune implicită la început
                out.println("<option value=''>-- Selectați un membru --</option>");
                out.println(results.toString());
            } else {
                // Dacă nu s-au găsit membri pentru proiect, returnam toți utilizatorii cu ierarhie mai mică
                out.println("<option value=''>-- Nu există membri în echipă - Selectați orice utilizator --</option>");
                
                String sqlAllUsers = "SELECT id, nume, prenume FROM useri JOIN tipuri t ON useri.tip = t.tip " +
                                    "WHERE t.ierarhie > ? ORDER BY nume, prenume";
                try (PreparedStatement stmtAll = connection.prepareStatement(sqlAllUsers)) {
                    stmtAll.setInt(1, userIerarhie);
                    try (ResultSet rsAll = stmtAll.executeQuery()) {
                        while (rsAll.next()) {
                            out.println("<option value='" + rsAll.getInt("id") + "'>" +
                                    rsAll.getString("nume") + " " + 
                                    rsAll.getString("prenume") + "</option>");
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            out.println("<option value=''>Eroare: " + e.getMessage() + "</option>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}