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
        System.out.println(projectId);
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
            
            // Mai întâi, verificăm dacă proiectul există
            String sqlCheckProject = "SELECT id, nume FROM proiecte WHERE id = ?";
            PreparedStatement checkStmt = connection.prepareStatement(sqlCheckProject);
            checkStmt.setInt(1, Integer.parseInt(projectId));
            ResultSet checkRs = checkStmt.executeQuery();
           
            
            if (!checkRs.next()) {
                out.println("<option value=''>-- Proiectul selectat nu există în baza de date --</option>");
                return;
            }
            System.out.println(checkRs.getInt("id"));
            
            String projectName = checkRs.getString("nume");
            
            
            // Verificăm dacă există echipe asociate proiectului
            String sqlCheckTeams = "SELECT id, nume FROM echipe WHERE id_prj = ?";
            checkStmt = connection.prepareStatement(sqlCheckTeams);
            checkStmt.setInt(1, Integer.parseInt(projectId));
            checkRs = checkStmt.executeQuery();
            
            if (!checkRs.next()) {
                out.println("<option value=''>-- Nu există echipe asociate proiectului '" + projectName + "' --</option>");
                // Încarcă toți utilizatorii ca alternativă
                String sqlAllUsers = "SELECT id, nume, prenume FROM useri ORDER BY nume, prenume";
                Statement allUsersStmt = connection.createStatement();
                ResultSet allUsersRs = allUsersStmt.executeQuery(sqlAllUsers);
                
                while (allUsersRs.next()) {
                    out.println("<option value='" + allUsersRs.getInt("id") + "'>" + 
                                allUsersRs.getString("nume") + " " + 
                                allUsersRs.getString("prenume") + "</option>");
                }
                
                allUsersRs.close();
                allUsersStmt.close();
                return;
            }
            
            // Colectăm ID-urile echipelor pentru a le folosi într-o singură interogare
            StringBuilder teamIds = new StringBuilder();
            do {
                if (teamIds.length() > 0) teamIds.append(",");
                teamIds.append(checkRs.getInt("id"));
            } while (checkRs.next());
            
            checkRs.close();
            checkStmt.close();
            
            // Verificăm membrii echipelor
            // Folosim o interogare directă care să listeze toți membrii din toate echipele asociate proiectului
            String sqlMembers = 
                "SELECT DISTINCT u.id, u.nume, u.prenume " +
                "FROM useri u " +
                "JOIN membrii_echipe me ON u.id = me.id_ang " +
                "WHERE me.id_echipa IN (" + teamIds.toString() + ") " +
                "ORDER BY u.nume, u.prenume";
            
            stmt = connection.prepareStatement(sqlMembers);
            rs = stmt.executeQuery();
            
            if (!rs.isBeforeFirst()) {  // Verificăm dacă rezultatul e gol
                out.println("<option value=''>-- Nu există membri în echipele proiectului '" + projectName + "' --</option>");
                
                // Încarcă toți utilizatorii ca alternativă
                String sqlAllUsers = "SELECT id, nume, prenume FROM useri ORDER BY nume, prenume";
                Statement allUsersStmt = connection.createStatement();
                ResultSet allUsersRs = allUsersStmt.executeQuery(sqlAllUsers);
                
                while (allUsersRs.next()) {
                    out.println("<option value='" + allUsersRs.getInt("id") + "'>" + 
                                allUsersRs.getString("nume") + " " + 
                                allUsersRs.getString("prenume") + "</option>");
                }
                
                allUsersRs.close();
                allUsersStmt.close();
            } else {
                // Avem membri în echipe
                while (rs.next()) {
                    out.println("<option value='" + rs.getInt("id") + "'>" + 
                                rs.getString("nume") + " " + 
                                rs.getString("prenume") + "</option>");
                }
            }
            
        } catch (ClassNotFoundException | SQLException e) {
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