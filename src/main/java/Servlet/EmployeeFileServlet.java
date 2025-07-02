package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.google.gson.Gson;
import bean.MyUser;

/**
 * EmployeeFileServlet - Backend pentru sistemul de dosare angajați
 * Gestionează încărcarea și vizualizarea datelor angajaților din baza de date
 */
public class EmployeeFileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Parametri conexiune baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Setare headers pentru JSON și CORS
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        PrintWriter out = response.getWriter();
        String action = request.getParameter("action");
        
        System.out.println("DEBUG: EmployeeFileServlet called with action: " + action);
        
        try {
            if ("loadEmployees".equals(action)) {
                loadEmployees(request, out);
            } else if ("getEmployeeDetails".equals(action)) {
                getEmployeeDetails(request, out);
            } else if ("loadFilters".equals(action)) {
                loadFilters(out);
            } else {
                sendErrorResponse(out, "Acțiune necunoscută: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare server: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Încarcă lista de angajați cu filtrare opțională
     */
    private void loadEmployees(HttpServletRequest request, PrintWriter out) {
        String searchName = request.getParameter("searchName");
        String filterDept = request.getParameter("filterDept");
        String filterPosition = request.getParameter("filterPosition");
        
        System.out.println("DEBUG: Loading employees with filters - Name: " + searchName + 
                          ", Dept: " + filterDept + ", Position: " + filterPosition);
        
        try (Connection conn = getConnection()) {
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT DISTINCT ");
            sql.append("    u.id, ");
            sql.append("    u.nume, ");
            sql.append("    u.prenume, ");
            sql.append("    u.email, ");
            sql.append("    u.telefon, ");
            sql.append("    t.salariu, ");
//            sql.append("    u.data_angajare as data_ang, ");
            sql.append("    u.activ, ");
            sql.append("    d.nume_dep as departament, ");
            sql.append("    t.denumire as pozitie, ");
            sql.append("    u.zilecons, ");
            sql.append("    u.zileramase, ");
            // Calcul sporuri active
            sql.append("    (SELECT GROUP_CONCAT(ts.denumire SEPARATOR ', ') ");
            sql.append("     FROM istoric_sporuri isp ");
            sql.append("     JOIN tipuri_sporuri ts ON isp.tip_spor = ts.id ");
            sql.append("     WHERE isp.id_ang = u.id ");
            sql.append("     AND isp.data_start <= CURDATE() ");
            sql.append("     AND isp.data_final >= CURDATE()) as sporuri_active, ");
            // Calcul penalizări active
            sql.append("    (SELECT GROUP_CONCAT(tp.denumire SEPARATOR ', ') ");
            sql.append("     FROM istoric_penalizari ipe ");
            sql.append("     JOIN tipuri_penalizari tp ON ipe.tip_penalizare = tp.id ");
            sql.append("     WHERE ipe.id_ang = u.id ");
            sql.append("     AND ipe.data_start <= CURDATE() ");
            sql.append("     AND ipe.data_final >= CURDATE()) as penalizari_active, ");
            // Număr promovări
            sql.append("    (SELECT COUNT(*) FROM istoric_promovari ip WHERE ip.id_ang = u.id) as numar_promovari ");
            sql.append("FROM useri u ");
            sql.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("JOIN tipuri t ON u.tip = t.tip ");
            sql.append("WHERE 1=1 ");
            
            List<Object> params = new ArrayList<>();
            
            // Filtru căutare nume
            if (searchName != null && !searchName.trim().isEmpty()) {
                sql.append("AND (u.nume LIKE ? OR u.prenume LIKE ? OR CONCAT(u.nume, ' ', u.prenume) LIKE ?) ");
                String searchPattern = "%" + searchName.trim() + "%";
                params.add(searchPattern);
                params.add(searchPattern);
                params.add(searchPattern);
            }
            
            // Filtru departament
            if (filterDept != null && !filterDept.trim().isEmpty()) {
                sql.append("AND d.nume_dep = ? ");
                params.add(filterDept);
            }
            
            // Filtru poziție
            if (filterPosition != null && !filterPosition.trim().isEmpty()) {
                sql.append("AND t.denumire = ? ");
                params.add(filterPosition);
            }
            
            sql.append("ORDER BY u.nume, u.prenume");
            
            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            System.out.println("DEBUG: Executing SQL: " + sql.toString());
            System.out.println("DEBUG: Parameters: " + params);
            
            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> employees = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> employee = new HashMap<>();
                employee.put("id", rs.getInt("id"));
                employee.put("nume", rs.getString("nume"));
                employee.put("prenume", rs.getString("prenume"));
                employee.put("email", rs.getString("email"));
                employee.put("telefon", rs.getString("telefon"));
                employee.put("salariu", rs.getInt("salariu"));
                employee.put("activ", rs.getBoolean("activ"));
                employee.put("departament", rs.getString("departament"));
                employee.put("pozitie", rs.getString("pozitie"));
                employee.put("zilecons", rs.getInt("zilecons"));
                employee.put("zileramase", rs.getInt("zileramase"));
//                employee.put("sporuri_active", rs.getString("sporuri_active"));
//                employee.put("penalizari_active", rs.getString("penalizari_active"));
//                employee.put("numar_promovari", rs.getInt("numar_promovari"));
                
                employees.add(employee);
            }
            
            System.out.println("DEBUG: Found " + employees.size() + " employees");
            
            // Răspuns JSON
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", employees);
            response.put("count", employees.size());
            
            Gson gson = new Gson();
            out.print(gson.toJson(response));
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea angajaților: " + e.getMessage());
        }
    }
    
    /**
     * Încarcă detaliile complete ale unui angajat
     */
    private void getEmployeeDetails(HttpServletRequest request, PrintWriter out) {
        String employeeIdStr = request.getParameter("employeeId");
        
        if (employeeIdStr == null || employeeIdStr.trim().isEmpty()) {
            sendErrorResponse(out, "ID angajat lipsește");
            return;
        }
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            System.out.println("DEBUG: Loading details for employee ID: " + employeeId);
            
            try (Connection conn = getConnection()) {
                // Query pentru informatii generale
                String sql = "SELECT u.*, d.nume_dep as departament, t.denumire as pozitie, t.salariu " +
                           "FROM useri u " +
                           "JOIN departament d ON u.id_dep = d.id_dep " +
                           "JOIN tipuri t ON u.tip = t.tip " +
                           "WHERE u.id = ?";
                
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, employeeId);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    Map<String, Object> employee = new HashMap<>();
                    employee.put("id", rs.getInt("id"));
                    employee.put("nume", rs.getString("nume"));
                    employee.put("prenume", rs.getString("prenume"));
                    employee.put("email", rs.getString("email"));
                    employee.put("telefon", rs.getString("telefon"));
                    employee.put("salariu", rs.getInt("salariu"));
//                    employee.put("data_ang", rs.getDate("data_angajare"));
                    employee.put("activ", rs.getBoolean("activ"));
                    employee.put("departament", rs.getString("departament"));
                    employee.put("pozitie", rs.getString("pozitie"));
                    employee.put("zilecons", rs.getInt("zilecons"));
                    employee.put("zileramase", rs.getInt("zileramase"));
                    
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", true);
                    response.put("employee", employee);
                    
                    Gson gson = new Gson();
                    out.print(gson.toJson(response));
                } else {
                    sendErrorResponse(out, "Angajatul cu ID-ul " + employeeId + " nu a fost găsit");
                }
                
            } catch (SQLException e) {
                e.printStackTrace();
                sendErrorResponse(out, "Eroare la încărcarea detaliilor angajatului: " + e.getMessage());
            }
            
        } catch (NumberFormatException e) {
            sendErrorResponse(out, "ID angajat invalid: " + employeeIdStr);
        }
    }
    
    /**
     * Încarcă opțiunile pentru filtre (departamente și poziții)
     */
    private void loadFilters(PrintWriter out) {
        System.out.println("DEBUG: Loading filter options");
        
        try (Connection conn = getConnection()) {
            Map<String, Object> filters = new HashMap<>();
            
            // Încarcă departamentele
            String deptSql = "SELECT DISTINCT nume_dep FROM departament ORDER BY nume_dep";
            PreparedStatement deptStmt = conn.prepareStatement(deptSql);
            ResultSet deptRs = deptStmt.executeQuery();
            
            List<String> departments = new ArrayList<>();
            while (deptRs.next()) {
                departments.add(deptRs.getString("nume_dep"));
            }
            
            // Încarcă pozițiile
            String posSql = "SELECT DISTINCT denumire FROM tipuri ORDER BY denumire";
            PreparedStatement posStmt = conn.prepareStatement(posSql);
            ResultSet posRs = posStmt.executeQuery();
            
            List<String> positions = new ArrayList<>();
            while (posRs.next()) {
                positions.add(posRs.getString("denumire"));
            }
            
            filters.put("departments", departments);
            filters.put("positions", positions);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("filters", filters);
            
            Gson gson = new Gson();
            out.print(gson.toJson(response));
            
            System.out.println("DEBUG: Loaded " + departments.size() + " departments and " + 
                             positions.size() + " positions");
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea filtrelor: " + e.getMessage());
        }
    }
    
    /**
     * Trimite răspuns de eroare în format JSON
     */
    private void sendErrorResponse(PrintWriter out, String errorMessage) {
        System.out.println("DEBUG: Sending error response: " + errorMessage);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("error", errorMessage);
        
        Gson gson = new Gson();
        out.print(gson.toJson(response));
    }
    
    /**
     * Obține conexiunea la baza de date
     */
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("DEBUG: MySQL JDBC Driver not found");
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        
        System.out.println("DEBUG: Getting database connection to: " + JDBC_URL);
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }
}