package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

import org.json.JSONArray;
import org.json.JSONObject;

public class QueryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(QueryServlet.class.getName());
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false&serverTimezone=UTC";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    private static final int QUERY_TIMEOUT = 30;
    private static final int MAX_ROWS = 1000;

    @Override
    public void init() throws ServletException {
        super.init();
        logger.info("🚀 QueryServlet initialized at /QueryServlet");
        
        // Test database connection
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = getConnection()) {
                if (conn != null && !conn.isClosed()) {
                    logger.info("✅ Database connection successful!");
                }
            }
        } catch (Exception e) {
            logger.severe("❌ Database connection failed: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // CORS headers
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json;charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            // Read JSON from Flask
            StringBuilder buffer = new StringBuilder();
            String line;
            BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            
            String jsonData = buffer.toString().trim();
            logger.info("📤 Received: " + jsonData);
            
            if (jsonData.isEmpty()) {
                sendErrorResponse(out, "Empty request", 400);
                return;
            }
            
            // Parse JSON
            JSONObject requestJson = new JSONObject(jsonData);
            String sqlQuery = requestJson.optString("query", "").trim();
            
            if (sqlQuery.isEmpty()) {
                sendErrorResponse(out, "No SQL query provided", 400);
                return;
            }
            
            logger.info("🔍 Executing: " + sqlQuery);
            
            // Basic security check
            if (!isQuerySafe(sqlQuery)) {
                sendErrorResponse(out, "Unsafe query", 403);
                return;
            }
            
            // Execute query
            QueryResult result = executeQuery(sqlQuery);
            
            // Build response
            JSONObject responseJson = new JSONObject();
            responseJson.put("success", result.isSuccess());
            responseJson.put("data", new JSONArray(result.getData()));
            responseJson.put("rowCount", result.getRowCount());
            responseJson.put("columns", new JSONArray(result.getColumnNames()));
            responseJson.put("executionTime", result.getExecutionTime() + "ms");
            responseJson.put("timestamp", System.currentTimeMillis());
            responseJson.put("message", result.getMessage());
            
            if (!result.isSuccess()) {
                responseJson.put("error", result.getError());
                response.setStatus(500);
            }
            
            out.println(responseJson.toString());
            logger.info("✅ Response sent - " + result.getRowCount() + " rows");
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "❌ Error", e);
            sendErrorResponse(out, "Internal error: " + e.getMessage(), 500);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json;charset=UTF-8");
        
        JSONObject statusJson = new JSONObject();
        statusJson.put("servlet", "QueryServlet");
        statusJson.put("status", "active");
        statusJson.put("mapping", "/QueryServlet");
        statusJson.put("timestamp", System.currentTimeMillis());
        
        // Test DB connection
        try (Connection conn = getConnection()) {
            statusJson.put("database", "connected");
        } catch (SQLException e) {
            statusJson.put("database", "error: " + e.getMessage());
        }
        
        response.getWriter().println(statusJson.toString());
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(200);
    }
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL driver not found", e);
        }
    }
    
    private QueryResult executeQuery(String sqlQuery) {
        QueryResult result = new QueryResult();
        long startTime = System.currentTimeMillis();
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sqlQuery)) {
            
            stmt.setQueryTimeout(QUERY_TIMEOUT);
            stmt.setMaxRows(MAX_ROWS);
            
            if (sqlQuery.trim().toUpperCase().startsWith("SELECT")) {
                try (ResultSet rs = stmt.executeQuery()) {
                    
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();
                    
                    // Column names
                    List<String> columnNames = new ArrayList<>();
                    for (int i = 1; i <= columnCount; i++) {
                        columnNames.add(metaData.getColumnLabel(i));
                    }
                    result.setColumnNames(columnNames);
                    
                    // Data rows
                    List<Map<String, Object>> data = new ArrayList<>();
                    int rowCount = 0;
                    
                    while (rs.next() && rowCount < MAX_ROWS) {
                        Map<String, Object> row = new HashMap<>();
                        
                        for (int i = 1; i <= columnCount; i++) {
                            String columnName = metaData.getColumnLabel(i);
                            Object value = rs.getObject(i);
                            
                            if (value == null) {
                                row.put(columnName, null);
                            } else if (value instanceof java.sql.Date || 
                                      value instanceof java.sql.Timestamp || 
                                      value instanceof java.sql.Time) {
                                row.put(columnName, value.toString());
                            } else {
                                row.put(columnName, value);
                            }
                        }
                        
                        data.add(row);
                        rowCount++;
                    }
                    
                    result.setData(data);
                    result.setRowCount(rowCount);
                    result.setSuccess(true);
                    result.setMessage("Query executed successfully");
                }
                
            } else {
                // UPDATE/INSERT/DELETE
                int affectedRows = stmt.executeUpdate();
                
                List<Map<String, Object>> data = new ArrayList<>();
                Map<String, Object> resultRow = new HashMap<>();
                resultRow.put("affected_rows", affectedRows);
                data.add(resultRow);
                
                result.setData(data);
                result.setRowCount(1);
                result.setColumnNames(List.of("affected_rows"));
                result.setSuccess(true);
                result.setMessage(affectedRows + " rows affected");
            }
            
        } catch (SQLException e) {
            result.setSuccess(false);
            result.setError("Database error: " + e.getMessage());
            result.setMessage("Query failed");
            result.setData(new ArrayList<>());
            result.setRowCount(0);
            result.setColumnNames(new ArrayList<>());
        }
        
        result.setExecutionTime(System.currentTimeMillis() - startTime);
        return result;
    }
    
    /**
     * Enhanced SQL injection protection
     */
    private boolean isQuerySafe(String query) {
        String upperQuery = query.toUpperCase().trim();
        
        // Allow CRUD operations + some utility queries
        if (!upperQuery.startsWith("SELECT") && 
            !upperQuery.startsWith("INSERT") && 
            !upperQuery.startsWith("UPDATE") && 
            !upperQuery.startsWith("DELETE") &&
            !upperQuery.startsWith("SHOW") &&      // Allow SHOW TABLES, SHOW COLUMNS, etc.
            !upperQuery.startsWith("DESCRIBE") &&  // Allow DESCRIBE table
            !upperQuery.startsWith("EXPLAIN")) {   // Allow EXPLAIN queries
            logger.warning("🚫 Blocked non-CRUD query: " + upperQuery.substring(0, Math.min(50, upperQuery.length())));
            return false;
        }
        
        // Allow specific SHOW commands that are safe
        if (upperQuery.startsWith("SHOW")) {
            if (upperQuery.contains("SHOW TABLES") ||
                upperQuery.contains("SHOW COLUMNS") ||
                upperQuery.contains("SHOW INDEX") ||
                upperQuery.contains("SHOW CREATE TABLE") ||
                upperQuery.matches("SHOW\\s+COLUMNS\\s+FROM\\s+\\w+.*") ||
                upperQuery.matches("SHOW\\s+INDEX\\s+FROM\\s+\\w+.*")) {
                return true; // These SHOW commands are safe
            }
        }
        
        // Block dangerous keywords but allow some exceptions
        String[] dangerousKeywords = {
            "DROP", "CREATE TABLE", "CREATE DATABASE", "ALTER", "TRUNCATE", 
            "GRANT", "REVOKE", "EXECUTE", "EXEC", "CALL", 
            "LOAD_FILE", "INTO OUTFILE", "SCRIPT", "SHUTDOWN"
        };
        
        for (String keyword : dangerousKeywords) {
            if (upperQuery.contains(keyword)) {
                // Exception: Allow CREATE in some contexts (like SHOW CREATE TABLE)
                if (keyword.equals("CREATE TABLE") && upperQuery.contains("SHOW CREATE TABLE")) {
                    continue; // This is safe
                }
                
                logger.warning("🚫 Blocked potentially dangerous query containing: " + keyword);
                return false;
            }
        }
        
        // Block SQL comments and multiple statements
        if (upperQuery.contains("--") || 
            upperQuery.contains("/*") || 
            upperQuery.contains("*/") ||
            upperQuery.contains(";") && !upperQuery.endsWith(";")) { // Allow single trailing semicolon
            logger.warning("🚫 Blocked query with comments or multiple statements");
            return false;
        }
        
        return true;
    }
    
    private void sendErrorResponse(PrintWriter out, String message, int statusCode) {
        JSONObject errorJson = new JSONObject();
        errorJson.put("success", false);
        errorJson.put("error", message);
        errorJson.put("statusCode", statusCode);
        errorJson.put("timestamp", System.currentTimeMillis());
        errorJson.put("data", new JSONArray());
        errorJson.put("rowCount", 0);
        
        out.println(errorJson.toString());
    }
    
    private static class QueryResult {
        private boolean success = false;
        private List<Map<String, Object>> data = new ArrayList<>();
        private int rowCount = 0;
        private List<String> columnNames = new ArrayList<>();
        private long executionTime = 0;
        private String message = "";
        private String error = "";
        
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public List<Map<String, Object>> getData() { return data; }
        public void setData(List<Map<String, Object>> data) { this.data = data; }
        
        public int getRowCount() { return rowCount; }
        public void setRowCount(int rowCount) { this.rowCount = rowCount; }
        
        public List<String> getColumnNames() { return columnNames; }
        public void setColumnNames(List<String> columnNames) { this.columnNames = columnNames; }
        
        public long getExecutionTime() { return executionTime; }
        public void setExecutionTime(long executionTime) { this.executionTime = executionTime; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public String getError() { return error; }
        public void setError(String error) { this.error = error; }
    }
}