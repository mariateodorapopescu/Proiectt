package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

/**
 * EmployeeDataServlet - Servlet pentru date specifice angajaților
 * Gestionează istoric salarial, promovări, sporuri, penalizări, concedii, proiecte
 */
public class EmployeeDataServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Parametri conexiune baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        PrintWriter out = response.getWriter();
        String action = request.getParameter("action");
        String employeeIdStr = request.getParameter("employeeId");
        
        System.out.println("DEBUG: EmployeeDataServlet called with action: " + action + ", employeeId: " + employeeIdStr);
        
        try {
            if (employeeIdStr == null || employeeIdStr.trim().isEmpty()) {
                sendErrorResponse(out, "ID angajat lipsește");
                return;
            }
            
            int employeeId = Integer.parseInt(employeeIdStr);
            
            switch (action) {
                case "salaryHistory":
                    getSalaryHistory(employeeId, out);
                    break;
                case "positionHistory":
                    getPositionHistory(employeeId, out);
                    break;
                case "bonusHistory":
                    getBonusHistory(employeeId, out);
                    break;
                case "penaltyHistory":
                    getPenaltyHistory(employeeId, out);
                    break;
                case "leaveHistory":
                    getLeaveHistory(employeeId, out);
                    break;
                case "projectsAndTasks":
                    getProjectsAndTasks(employeeId, out);
                    break;
                default:
                    sendErrorResponse(out, "Acțiune necunoscută: " + action);
            }
            
        } catch (NumberFormatException e) {
            sendErrorResponse(out, "ID angajat invalid: " + employeeIdStr);
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
     * Obține istoricul salarial al angajatului
     */
    private void getSalaryHistory(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting salary history for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT " +
                        "    hf.luna, " +
                        "    hf.an, " +
                        "    hf.salariu_brut, " +
                        "    hf.salariu_net, " +
                        "    hf.data_generare " +
                        "FROM istoric_fluture hf " +
                        "WHERE hf.id_ang = ? " +
                        "ORDER BY hf.an DESC, hf.luna DESC " +
                        "LIMIT 24"; // Ultimele 2 ani
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> salaryHistory = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("luna", rs.getInt("luna"));
                record.put("an", rs.getInt("an"));
                record.put("salariu_brut", rs.getDouble("salariu_brut"));
                record.put("salariu_net", rs.getDouble("salariu_net"));
                record.put("data_generare", rs.getTimestamp("data_generare"));
                salaryHistory.add(record);
            }
            
            sendSuccessResponse(out, salaryHistory);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea istoricului salarial: " + e.getMessage());
        }
    }
    
    /**
     * Obține istoricul promovărilor
     */
    private void getPositionHistory(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting position history for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT " +
                        "    ip.data_promovare, " +
                        "    t1.denumire as pozitie_veche, " +
                        "    t2.denumire as pozitie_noua, " +
                        "    ip.tip_promovare " +
                        "FROM istoric_promovari ip " +
                        "JOIN tipuri t1 ON ip.tip_vechi = t1.tip " +
                        "JOIN tipuri t2 ON ip.tip_nou = t2.tip " +
                        "WHERE ip.id_ang = ? " +
                        "ORDER BY ip.data_promovare DESC";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> positionHistory = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("data_promovare", rs.getDate("data_promovare"));
                record.put("pozitie_veche", rs.getString("pozitie_veche"));
                record.put("pozitie_noua", rs.getString("pozitie_noua"));
                record.put("tip_promovare", rs.getString("tip_promovare"));
                positionHistory.add(record);
            }
            
            sendSuccessResponse(out, positionHistory);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea istoricului promovărilor: " + e.getMessage());
        }
    }
    
    /**
     * Obține istoricul sporurilor active
     */
    private void getBonusHistory(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting bonus history for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT " +
                        "    ts.denumire as tip_spor, " +
                        "    ts.procent, " +
                        "    isp.data_start, " +
                        "    isp.data_final, " +
                        "    isp.motiv " +
                        "FROM istoric_sporuri isp " +
                        "JOIN tipuri_sporuri ts ON isp.tip_spor = ts.id " +
                        "WHERE isp.id_ang = ? " +
                        "AND isp.data_start <= CURDATE() " +
                        "AND isp.data_final >= CURDATE() " +
                        "ORDER BY isp.data_start DESC";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> bonusHistory = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("tip_spor", rs.getString("tip_spor"));
                record.put("procent", rs.getDouble("procent"));
                record.put("data_start", rs.getDate("data_start"));
                record.put("data_final", rs.getDate("data_final"));
                record.put("motiv", rs.getString("motiv"));
                bonusHistory.add(record);
            }
            
            sendSuccessResponse(out, bonusHistory);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea sporurilor: " + e.getMessage());
        }
    }
    
    /**
     * Obține istoricul penalizărilor active
     */
    private void getPenaltyHistory(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting penalty history for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT " +
                        "    tp.denumire as tip_penalizare, " +
                        "    tp.procent, " +
                        "    ipe.data_start, " +
                        "    ipe.data_final, " +
                        "    ipe.motiv " +
                        "FROM istoric_penalizari ipe " +
                        "JOIN tipuri_penalizari tp ON ipe.tip_penalizare = tp.id " +
                        "WHERE ipe.id_ang = ? " +
                        "AND ipe.data_start <= CURDATE() " +
                        "AND ipe.data_final >= CURDATE() " +
                        "ORDER BY ipe.data_start DESC";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> penaltyHistory = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("tip_penalizare", rs.getString("tip_penalizare"));
                record.put("procent", rs.getDouble("procent"));
                record.put("data_start", rs.getDate("data_start"));
                record.put("data_final", rs.getDate("data_final"));
                record.put("motiv", rs.getString("motiv"));
                penaltyHistory.add(record);
            }
            
            sendSuccessResponse(out, penaltyHistory);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea penalizărilor: " + e.getMessage());
        }
    }
    
    /**
     * Obține istoricul concediilor
     */
    private void getLeaveHistory(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting leave history for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT " +
                        "    tc.motiv as tip_concediu, " +
                        "    c.start_c, " +
                        "    c.end_c, " +
                        "    DATEDIFF(c.end_c, c.start_c) + 1 as zile, " +
                        "    s.nume_status as status, " +
                        "    c.motiv " +
                        "FROM concedii c " +
                        "JOIN tipcon tc ON c.tip = tc.tip " +
                        "JOIN statusuri s ON c.status = s.status " +
                        "WHERE c.id_ang = ? " +
                        "ORDER BY c.start_c DESC " +
                        "LIMIT 50";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> leaveHistory = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("tip_concediu", rs.getString("tip_concediu"));
                record.put("start_c", rs.getDate("start_c"));
                record.put("end_c", rs.getDate("end_c"));
                record.put("zile", rs.getInt("zile"));
                record.put("status", rs.getString("status"));
                record.put("motiv", rs.getString("motiv"));
                leaveHistory.add(record);
            }
            
            sendSuccessResponse(out, leaveHistory);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea istoricului concediilor: " + e.getMessage());
        }
    }
    
    /**
     * Obține proiectele și task-urile angajatului
     */
    private void getProjectsAndTasks(int employeeId, PrintWriter out) {
        System.out.println("DEBUG: Getting projects and tasks for employee: " + employeeId);
        
        try (Connection conn = getConnection()) {
            Map<String, Object> result = new HashMap<>();
            
            // Proiecte active
            String projectsSql = "SELECT DISTINCT " +
                               "    p.nume as nume_proiect, " +
                               "    p.descriere, " +
                               "    p.start, " +
                               "    p.end, " +
                               "    e.nume as nume_echipa " +
                               "FROM proiecte p " +
                               "JOIN echipe e ON p.id = e.id_prj " +
                               "JOIN membrii_echipe me ON e.id = me.id_echipa " +
                               "WHERE me.id_ang = ? " +
                               "AND p.start <= CURDATE() " +
                               "AND p.end >= CURDATE() " +
                               "ORDER BY p.start DESC";
            
            PreparedStatement projectsStmt = conn.prepareStatement(projectsSql);
            projectsStmt.setInt(1, employeeId);
            ResultSet projectsRs = projectsStmt.executeQuery();
            
            List<Map<String, Object>> projects = new ArrayList<>();
            while (projectsRs.next()) {
                Map<String, Object> project = new HashMap<>();
                project.put("nume_proiect", projectsRs.getString("nume_proiect"));
                project.put("descriere", projectsRs.getString("descriere"));
                project.put("start", projectsRs.getDate("start"));
                project.put("end", projectsRs.getDate("end"));
                project.put("nume_echipa", projectsRs.getString("nume_echipa"));
                projects.add(project);
            }
            
            // Task-uri asignate
            String tasksSql = "SELECT " +
                             "    t.nume as nume_task, " +
                             "    t.start, " +
                             "    t.end, " +
                             "    s.procent as progres, " +
                             "    p.nume as nume_proiect " +
                             "FROM tasks t " +
                             "LEFT JOIN statusuri2 s ON t.status = s.id " +
                             "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                             "WHERE t.id_ang = ? " +
                             "AND (t.end IS NULL OR t.end >= CURDATE()) " +
                             "ORDER BY t.start DESC " +
                             "LIMIT 20";
            
            PreparedStatement tasksStmt = conn.prepareStatement(tasksSql);
            tasksStmt.setInt(1, employeeId);
            ResultSet tasksRs = tasksStmt.executeQuery();
            
            List<Map<String, Object>> tasks = new ArrayList<>();
            while (tasksRs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("nume_task", tasksRs.getString("nume_task"));
                task.put("start", tasksRs.getDate("start"));
                task.put("end", tasksRs.getDate("end"));
                task.put("progres", tasksRs.getInt("progres"));
                task.put("nume_proiect", tasksRs.getString("nume_proiect"));
                tasks.add(task);
            }
            
            result.put("projects", projects);
            result.put("tasks", tasks);
            
            sendSuccessResponse(out, result);
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la încărcarea proiectelor și task-urilor: " + e.getMessage());
        }
    }
    
    /**
     * Trimite răspuns de succes
     */
    private void sendSuccessResponse(PrintWriter out, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", data);
        
        Gson gson = new Gson();
        out.print(gson.toJson(response));
    }
    
    /**
     * Trimite răspuns de eroare
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