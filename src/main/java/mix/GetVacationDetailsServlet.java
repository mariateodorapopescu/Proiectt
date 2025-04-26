package mix;import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import org.json.*;
import java.util.*;

public class GetVacationDetailsServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        int userType = Integer.parseInt(request.getParameter("userType"));
        int userId = Integer.parseInt(request.getParameter("userId"));
        int userDep = Integer.parseInt(request.getParameter("userDep"));
        String deptId = request.getParameter("deptId");
        String empId = request.getParameter("empId");
        String statusId = request.getParameter("statusId");
        
        List<Map<String, Object>> vacations = new ArrayList<>();
        
        try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            
            StringBuilder queryBuilder = new StringBuilder(
                "SELECT c.id, c.start_c, c.end_c, c.motiv, c.status, " +
                "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as address, " +
                "u.nume, u.prenume, d.nume_dep as departament, u.culoare as color, " +
                "s.nume_status as statusText " +
                "FROM concedii c " +
                "JOIN useri u ON u.id = c.id_ang " +
                "JOIN departament d ON u.id_dep = d.id_dep " +
                "JOIN statusuri s ON c.status = s.status " +
                "LEFT JOIN locatii_concedii l ON c.id = l.id_concediu " +
                "WHERE 1=1"
            );
            
            List<Object> params = new ArrayList<>();
            
            // Filter by status if provided
            if (statusId != null && !statusId.isEmpty()) {
                queryBuilder.append(" AND c.status = ?");
                params.add(Integer.parseInt(statusId));
            }
            
            // Access control logic
            if (empId != null && !empId.isEmpty()) {
                // Specific employee selected
                queryBuilder.append(" AND u.id = ?");
                params.add(Integer.parseInt(empId));
            } else if (deptId != null && !deptId.isEmpty()) {
                // Specific department selected
                queryBuilder.append(" AND u.id_dep = ?");
                params.add(Integer.parseInt(deptId));
            } else {
                // Default behavior based on user type
                if (userType == 3) { // Sef - only their department
                    queryBuilder.append(" AND u.id_dep = ?");
                    params.add(userDep);
                } else if (userType == 0 || (userType >= 12 && userType <= 19)) { 
                    // Director - all departments (no additional filter)
                } else { 
                    // Regular users - only their own vacations
                    queryBuilder.append(" AND u.id = ?");
                    params.add(userId);
                }
            }
            
            PreparedStatement stmt = conn.prepareStatement(queryBuilder.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> vacation = new HashMap<>();
                vacation.put("id", rs.getInt("id"));
                vacation.put("start_c", rs.getDate("start_c").toString());
                vacation.put("end_c", rs.getDate("end_c").toString());
                vacation.put("motiv", rs.getString("motiv"));
                vacation.put("address", rs.getString("address"));
                vacation.put("nume", rs.getString("nume"));
                vacation.put("prenume", rs.getString("prenume"));
                vacation.put("departament", rs.getString("departament"));
                vacation.put("color", rs.getString("color"));
                vacation.put("status", rs.getInt("status"));
                vacation.put("statusText", rs.getString("statusText"));
                vacations.add(vacation);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        
        response.getWriter().write(new JSONArray(vacations).toString());
    }
}