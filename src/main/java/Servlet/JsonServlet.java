package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;
import bean.MyUser;

public class JsonServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        
        // Get parameters from the form
        String statusParam = request.getParameter("status");
        String departmentParam = request.getParameter("dep");
        String tipConcediuParam = request.getParameter("tip_concediu");
        String tipParam = request.getParameter("tip");
        String monthParam = request.getParameter("month");
        String userIdParam = request.getParameter("user_id");
        
        int status = 3; // Default: Any status
        int department = -1; // Default: Any department
        int tipConcediu = -1; // Default: Any leave type
        int type = 1; // Default report type: Annual
        int month = -1; // Default: No specific month
        int userId = -1; // Default: No specific user
        
        try {
            if (statusParam != null && !statusParam.isEmpty()) {
                status = Integer.parseInt(statusParam);
            }
            if (departmentParam != null && !departmentParam.isEmpty()) {
                department = Integer.parseInt(departmentParam);
            }
            if (tipConcediuParam != null && !tipConcediuParam.isEmpty()) {
                tipConcediu = Integer.parseInt(tipConcediuParam);
            }
            if (tipParam != null && !tipParam.isEmpty()) {
                type = Integer.parseInt(tipParam);
            }
            if (monthParam != null && !monthParam.isEmpty()) {
                month = Integer.parseInt(monthParam);
            }
            if (userIdParam != null && !userIdParam.isEmpty()) {
                userId = Integer.parseInt(userIdParam);
            }
        } catch (NumberFormatException e) {
            System.out.println("Error parsing parameters: " + e.getMessage());
        }
        
        JSONObject jsonResponse = new JSONObject();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Fetch status name
                String statusName = "Toate statusurile"; // Default
                if (status != 3) {
                    try (PreparedStatement statusStmt = conn.prepareStatement("SELECT nume_status FROM statusuri WHERE status = ?")) {
                        statusStmt.setInt(1, status);
                        try (ResultSet statusRs = statusStmt.executeQuery()) {
                            if (statusRs.next()) {
                                statusName = statusRs.getString("nume_status");
                            }
                        }
                    }
                }
                
                // Fetch department name
                String departmentName = "Toate departamentele"; // Default
                if (department != -1) {
                    try (PreparedStatement deptStmt = conn.prepareStatement("SELECT nume_dep FROM departament WHERE id_dep = ?")) {
                        deptStmt.setInt(1, department);
                        try (ResultSet deptRs = deptStmt.executeQuery()) {
                            if (deptRs.next()) {
                                departmentName = deptRs.getString("nume_dep");
                            }
                        }
                    }
                }
                
                // Fetch user name if userId is provided
                String userName = null;
                if (userId != -1) {
                    try (PreparedStatement userStmt = conn.prepareStatement("SELECT CONCAT(nume, ' ', prenume) as full_name FROM useri WHERE id = ?")) {
                        userStmt.setInt(1, userId);
                        try (ResultSet userRs = userStmt.executeQuery()) {
                            if (userRs.next()) {
                                userName = userRs.getString("full_name");
                                departmentName = userName; // Override department name with user name for display
                            }
                        }
                    }
                }
                
                // Fetch tip concediu name
                String tipConcediuName = "Toate tipurile"; // Default
                if (tipConcediu != -1) {
                    try (PreparedStatement tipStmt = conn.prepareStatement("SELECT motiv FROM tipcon WHERE tip = ?")) {
                        tipStmt.setInt(1, tipConcediu);
                        try (ResultSet tipRs = tipStmt.executeQuery()) {
                            if (tipRs.next()) {
                                tipConcediuName = tipRs.getString("motiv");
                            }
                        }
                    }
                }
                
                if (type == 2 && month != -1) {
                    // Monthly report with daily breakdown
                    generateMonthlyReport(conn, jsonResponse, status, department, tipConcediu, month, userId, statusName, departmentName, tipConcediuName);
                } else {
                    // Annual report with monthly breakdown (default)
                    generateAnnualReport(conn, jsonResponse, status, department, tipConcediu, userId, statusName, departmentName, tipConcediuName);
                }
                
                out.print(jsonResponse.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", e.getMessage());
            out.print(error.toString());
        }
    }
    
    private void generateAnnualReport(Connection conn, JSONObject jsonResponse, int status, int department, int tipConcediu, 
                               int userId, String statusName, String departmentName, String tipConcediuName) throws SQLException {
        // Build the base query for annual report (by month)
        StringBuilder queryBuilder = new StringBuilder();
        queryBuilder.append("SELECT MONTH(c.start_c) as month, YEAR(c.start_c) as year, COUNT(*) as count ")
                   .append("FROM concedii c ")
                   .append("JOIN useri u ON c.id_ang = u.id where year(c.start_c) = year(current_date())");
        
        boolean whereAdded = true;
        
        // Add status condition if needed
        if (status != 3) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.status = ?");
            whereAdded = true;
        }
        
        // Add department condition if needed
        if (department != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("u.id_dep = ?");
            whereAdded = true;
        }
        
        // Add user_id condition if needed
        if (userId != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.id_ang = ?");
            whereAdded = true;
        }
        
        // Add tip concediu condition if needed
        if (tipConcediu != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.tip = ?");
            whereAdded = true;
        }
        
        // Group by month and year
        queryBuilder.append(" GROUP BY YEAR(c.start_c), MONTH(c.start_c) ORDER BY YEAR(c.start_c), MONTH(c.start_c)");
        
        String finalQuery = queryBuilder.toString();
        
        // Execute the query with parameters
        try (PreparedStatement stmt = conn.prepareStatement(finalQuery)) {
            int paramIndex = 1;
            
            if (status != 3) {
                stmt.setInt(paramIndex++, status);
            }
            
            if (department != -1) {
                stmt.setInt(paramIndex++, department);
            }
            
            if (userId != -1) {
                stmt.setInt(paramIndex++, userId);
            }
            
            if (tipConcediu != -1) {
                stmt.setInt(paramIndex++, tipConcediu);
            }
            
            Map<String, Integer> monthCounts = new TreeMap<>(); // TreeMap to keep months in order
            String[] monthNames = {"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", 
                                  "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"};
            
            // Execute query and process results
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int month = rs.getInt("month");
                    int year = rs.getInt("year");
                    int count = rs.getInt("count");
                    
                    String monthKey = monthNames[month-1] + " " + year;
                    monthCounts.put(monthKey, count);
                }
            }
            
            // Create JSON arrays for chart data
            JSONArray monthsArray = new JSONArray();
            JSONArray countsArray = new JSONArray();
            
            for (Map.Entry<String, Integer> entry : monthCounts.entrySet()) {
                monthsArray.put(entry.getKey());
                countsArray.put(entry.getValue());
            }
            
            // Build response JSON
            StringBuilder titleBuilder = new StringBuilder("Raport concedii");
            if (!statusName.equals("Toate statusurile")) {
                titleBuilder.append(" - ").append(statusName);
            }
            if (userId != -1) {
                titleBuilder.append(" - ").append(departmentName); // departmentName contains user name in this case
            } else if (!departmentName.equals("Toate departamentele")) {
                titleBuilder.append(" - ").append(departmentName);
            }
            if (!tipConcediuName.equals("Toate tipurile")) {
                titleBuilder.append(" - ").append(tipConcediuName);
            }
            
            jsonResponse.put("h3", titleBuilder.toString());
            jsonResponse.put("months", monthsArray);
            jsonResponse.put("counts", countsArray);
            jsonResponse.put("status", String.valueOf(status));
            jsonResponse.put("statusName", statusName);
            jsonResponse.put("departament", departmentName);
            jsonResponse.put("tipConcediuName", tipConcediuName);
        }
    }
    
    private void generateMonthlyReport(Connection conn, JSONObject jsonResponse, int status, int department, int tipConcediu, 
                                int month, int userId, String statusName, String departmentName, String tipConcediuName) throws SQLException {
        // Get current year
        int currentYear = LocalDate.now().getYear();
        
        // Determine the number of days in the specified month
        YearMonth yearMonthObject = YearMonth.of(currentYear, month);
        int daysInMonth = yearMonthObject.lengthOfMonth();
        
        // Build the query for daily report within the specified month
        StringBuilder queryBuilder = new StringBuilder();
        queryBuilder.append("SELECT DAY(date_range.date) as day, COALESCE(COUNT(c.id), 0) as count ")
                   .append("FROM (");
        
        // Generate a range of dates for the month
        for (int i = 1; i <= daysInMonth; i++) {
            if (i > 1) queryBuilder.append(" UNION ALL ");
            queryBuilder.append("SELECT '").append(currentYear).append("-").append(month).append("-").append(i).append("' as date");
        }
        
        queryBuilder.append(") as date_range ")
                   .append("LEFT JOIN concedii c ON date_range.date BETWEEN c.start_c AND c.end_c ")
                   .append("LEFT JOIN useri u ON c.id_ang = u.id ");
        
        // Add WHERE conditions
        boolean whereAdded = false;
        
        if (status != 3) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.status = ?");
            whereAdded = true;
        }
        
        if (department != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("u.id_dep = ?");
            whereAdded = true;
        }
        
        if (userId != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.id_ang = ?");
            whereAdded = true;
        }
        
        if (tipConcediu != -1) {
            queryBuilder.append(whereAdded ? " AND " : " WHERE ");
            queryBuilder.append("c.tip = ?");
            whereAdded = true;
        }
        
        // Group by day and order by day
        queryBuilder.append(" GROUP BY date_range.date ")
                   .append("ORDER BY date_range.date");
        
        String finalQuery = queryBuilder.toString();
        
        // Execute the query with parameters
        try (PreparedStatement stmt = conn.prepareStatement(finalQuery)) {
            int paramIndex = 1;
            
            if (status != 3) {
                stmt.setInt(paramIndex++, status);
            }
            
            if (department != -1) {
                stmt.setInt(paramIndex++, department);
            }
            
            if (userId != -1) {
                stmt.setInt(paramIndex++, userId);
            }
            
            if (tipConcediu != -1) {
                stmt.setInt(paramIndex++, tipConcediu);
            }
            
            // Execute query and process results
            JSONArray daysArray = new JSONArray();
            JSONArray countsArray = new JSONArray();
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int day = rs.getInt("day");
                    int count = rs.getInt("count");
                    
                    daysArray.put(day);
                    countsArray.put(count);
                }
            }
            
            // Get the month name
            String[] monthNames = {"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", 
                                  "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"};
            String monthName = monthNames[month-1];
            
            // Build response JSON
            StringBuilder titleBuilder = new StringBuilder();
            if (userId != -1) {
                titleBuilder.append("Raport concedii personale pentru luna ").append(monthName);
            } else {
                titleBuilder.append("Raport concedii pentru luna ").append(monthName);
            }
            
            if (!statusName.equals("Toate statusurile")) {
                titleBuilder.append(" - ").append(statusName);
            }
            if (userId == -1 && !departmentName.equals("Toate departamentele")) {
                titleBuilder.append(" - ").append(departmentName);
            }
            if (!tipConcediuName.equals("Toate tipurile")) {
                titleBuilder.append(" - ").append(tipConcediuName);
            }
            
            jsonResponse.put("h3", titleBuilder.toString());
            jsonResponse.put("months", daysArray); // Reusing "months" key for days for compatibility
            jsonResponse.put("counts", countsArray);
            jsonResponse.put("status", String.valueOf(status));
            jsonResponse.put("statusName", statusName);
            jsonResponse.put("departament", departmentName);
            jsonResponse.put("tipConcediuName", tipConcediuName);
            jsonResponse.put("monthName", monthName);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}