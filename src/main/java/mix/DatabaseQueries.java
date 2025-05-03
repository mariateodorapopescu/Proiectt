package mix;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Utility class to retrieve data from the database for the chat assistant
 */
public class DatabaseQueries {
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";
    
    // Helper method to close database resources
    private static void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Helper method to format date
    private static String formatDate(Date date) {
        if (date == null) return null;
        SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
        return sdf.format(date);
    }
    
    /**
     * Get all employees from the database
     */
    public static JSONArray getEmployees() {
        JSONArray employees = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, " +
                         "t.denumire AS functie, u.email, u.telefon " +
                         "FROM useri u " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "ORDER BY u.nume, u.prenume";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject employee = new JSONObject();
                employee.put("id", rs.getInt("id"));
                employee.put("nume", rs.getString("nume"));
                employee.put("prenume", rs.getString("prenume"));
                employee.put("departament", rs.getString("departament"));
                employee.put("functie", rs.getString("functie"));
                employee.put("email", rs.getString("email"));
                employee.put("telefon", rs.getString("telefon"));
                
                ((List<Object>) employees).add(employee);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return employees;
    }
    
    /**
     * Get employees filtered by department
     */
    public static JSONArray getEmployeesByDepartment(String department) {
        JSONArray employees = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, " +
                         "t.denumire AS functie, u.email, u.telefon " +
                         "FROM useri u " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "WHERE d.nume_dep LIKE ? " +
                         "ORDER BY u.nume, u.prenume";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, "%" + department + "%");
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject employee = new JSONObject();
                employee.put("id", rs.getInt("id"));
                employee.put("nume", rs.getString("nume"));
                employee.put("prenume", rs.getString("prenume"));
                employee.put("departament", rs.getString("departament"));
                employee.put("functie", rs.getString("functie"));
                employee.put("email", rs.getString("email"));
                employee.put("telefon", rs.getString("telefon"));
                
                ((List<Object>) employees).add(employee);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return employees;
    }
    
    /**
     * Get all departments
     */
    public static JSONArray getDepartments() {
        JSONArray departments = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT d.id_dep, d.nume_dep, COUNT(u.id) AS nr_angajati " +
                         "FROM departament d " +
                         "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                         "GROUP BY d.id_dep, d.nume_dep " +
                         "ORDER BY d.nume_dep";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject department = new JSONObject();
                department.put("id_dep", rs.getInt("id_dep"));
                department.put("nume_dep", rs.getString("nume_dep"));
                department.put("nr_angajati", rs.getInt("nr_angajati"));
                
                ((List<Object>) departments).add(department);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return departments;
    }
    
    /**
     * Get all leaves (concedii)
     */
    public static JSONArray getLeaves() {
        JSONArray leaves = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT c.id, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, " +
                         "t.denumire AS functie, c.start_c, c.end_c, c.durata, " +
                         "c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tip_concediu " +
                         "FROM concedii c " +
                         "JOIN useri u ON c.id_ang = u.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "JOIN statusuri s ON c.status = s.status " +
                         "JOIN tipcon ct ON c.tip = ct.tip " +
                         "ORDER BY c.start_c DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject leave = new JSONObject();
                leave.put("id", rs.getInt("id"));
                leave.put("id_ang", rs.getInt("id_ang"));
                leave.put("nume", rs.getString("nume"));
                leave.put("prenume", rs.getString("prenume"));
                leave.put("departament", rs.getString("departament"));
                leave.put("functie", rs.getString("functie"));
                leave.put("start_c", formatDate(rs.getDate("start_c")));
                leave.put("end_c", formatDate(rs.getDate("end_c")));
                leave.put("durata", rs.getInt("durata"));
                leave.put("motiv", rs.getString("motiv"));
                leave.put("tip_concediu", rs.getString("tip_concediu"));
                leave.put("locatie", rs.getString("locatie"));
                leave.put("status", rs.getString("status"));
                
                ((List<Object>) leaves).add(leave);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return leaves;
    }
    
    /**
     * Get leaves (concedii) for Christmas period
     */
    public static JSONArray getChristmasLeaves() {
        JSONArray leaves = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT c.id, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, " +
                         "t.denumire AS functie, c.start_c, c.end_c, c.durata, " +
                         "c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tip_concediu " +
                         "FROM concedii c " +
                         "JOIN useri u ON c.id_ang = u.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "JOIN statusuri s ON c.status = s.status " +
                         "JOIN tipcon ct ON c.tip = ct.tip " +
                         "WHERE ((c.start_c <= '2024-12-25' AND c.end_c >= '2024-12-24') OR " +
                         "(c.start_c <= '2023-12-25' AND c.end_c >= '2023-12-24')) " + 
                         "AND c.status >= 0 " +
                         "ORDER BY c.start_c DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject leave = new JSONObject();
                leave.put("id", rs.getInt("id"));
                leave.put("id_ang", rs.getInt("id_ang"));
                leave.put("nume", rs.getString("nume"));
                leave.put("prenume", rs.getString("prenume"));
                leave.put("departament", rs.getString("departament"));
                leave.put("functie", rs.getString("functie"));
                leave.put("start_c", formatDate(rs.getDate("start_c")));
                leave.put("end_c", formatDate(rs.getDate("end_c")));
                leave.put("durata", rs.getInt("durata"));
                leave.put("motiv", rs.getString("motiv"));
                leave.put("tip_concediu", rs.getString("tip_concediu"));
                leave.put("locatie", rs.getString("locatie"));
                leave.put("status", rs.getString("status"));
                
                ((List<Object>) leaves).add(leave);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return leaves;
    }
    
    /**
     * Get current leaves (concedii)
     */
    public static JSONArray getCurrentLeaves() {
        JSONArray leaves = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT c.id, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, " +
                         "t.denumire AS functie, c.start_c, c.end_c, c.durata, " +
                         "c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tip_concediu " +
                         "FROM concedii c " +
                         "JOIN useri u ON c.id_ang = u.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "JOIN statusuri s ON c.status = s.status " +
                         "JOIN tipcon ct ON c.tip = ct.tip " +
                         "WHERE CURDATE() BETWEEN c.start_c AND c.end_c " +
                         "AND c.status >= 0 " +
                         "ORDER BY c.start_c DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject leave = new JSONObject();
                leave.put("id", rs.getInt("id"));
                leave.put("id_ang", rs.getInt("id_ang"));
                leave.put("nume", rs.getString("nume"));
                leave.put("prenume", rs.getString("prenume"));
                leave.put("departament", rs.getString("departament"));
                leave.put("functie", rs.getString("functie"));
                leave.put("start_c", formatDate(rs.getDate("start_c")));
                leave.put("end_c", formatDate(rs.getDate("end_c")));
                leave.put("durata", rs.getInt("durata"));
                leave.put("motiv", rs.getString("motiv"));
                leave.put("tip_concediu", rs.getString("tip_concediu"));
                leave.put("locatie", rs.getString("locatie"));
                leave.put("status", rs.getString("status"));
                
                ((List<Object>) leaves).add(leave);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return leaves;
    }
    
    /**
     * Get all documents (adeverinte)
     */
    public static JSONArray getDocuments() {
        JSONArray documents = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, " +
                         "a.creare, a.modif " +
                         "FROM adeverinte a " +
                         "JOIN tip_adev ta ON a.tip = ta.id " +
                         "JOIN statusuri s ON a.status = s.status " +
                         "ORDER BY a.creare DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject document = new JSONObject();
                document.put("id", rs.getInt("id"));
                document.put("tip", rs.getString("tip_adeverinta"));
                document.put("motiv", rs.getString("motiv"));
                document.put("status", rs.getString("status"));
                document.put("creare", formatDate(rs.getDate("creare")));
                document.put("modif", formatDate(rs.getDate("modif")));
                
                ((List<Object>) documents).add(document);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return documents;
    }
    
    /**
     * Get all projects (proiecte)
     */
    public static JSONArray getProjects() {
        JSONArray projects = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT p.id, p.nume, p.descriere, p.start, p.end, " +
                         "COUNT(DISTINCT e.id) AS nr_echipe, " +
                         "COUNT(DISTINCT t.id) AS nr_taskuri " +
                         "FROM proiecte p " +
                         "LEFT JOIN echipe e ON p.id = e.id_prj " +
                         "LEFT JOIN tasks t ON p.id = t.id_prj " +
                         "GROUP BY p.id, p.nume, p.descriere, p.start, p.end " +
                         "ORDER BY p.start DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject project = new JSONObject();
                project.put("id", rs.getInt("id"));
                project.put("nume", rs.getString("nume"));
                project.put("descriere", rs.getString("descriere"));
                project.put("start", formatDate(rs.getDate("start")));
                project.put("end", formatDate(rs.getDate("end")));
                project.put("nr_echipe", rs.getInt("nr_echipe"));
                project.put("nr_taskuri", rs.getInt("nr_taskuri"));
                
                ((List<Object>) projects).add(project);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return projects;
    }
    
    /**
     * Generic method to execute a custom SQL query and return results as JSONArray
     */
    public static JSONArray executeCustomQuery(String sql, List<Object> params) {
        JSONArray results = new JSONArray();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            stmt = conn.prepareStatement(sql);
            
            // Set parameters if any
            if (params != null) {
                for (int i = 0; i < params.size(); i++) {
                    Object param = params.get(i);
                    if (param instanceof String) {
                        stmt.setString(i + 1, (String) param);
                    } else if (param instanceof Integer) {
                        stmt.setInt(i + 1, (Integer) param);
                    } else if (param instanceof Date) {
                        stmt.setDate(i + 1, new java.sql.Date(((Date) param).getTime()));
                    }
                    // Add more types as needed
                }
            }
            
            rs = stmt.executeQuery();
            
            // Get metadata to know column names
            java.sql.ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            // Process results
            while (rs.next()) {
                JSONObject result = new JSONObject();
                
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = metaData.getColumnLabel(i);
                    Object value = rs.getObject(i);
                    
                    // Format dates
                    if (value instanceof java.sql.Date) {
                        value = formatDate((java.sql.Date) value);
                    }
                    
                    result.put(columnName, value);
                }
                
                ((List<Object>) results).add(result);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return results;
    }
}