package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import java.io.BufferedReader;

/**
 * Servlet pentru actualizarea locației unui sediu
 */

public class UpdateSediutLocatieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public UpdateSediutLocatieServlet() {
        super();
    }
    
    /**
     * Metodă pentru procesarea cererilor POST
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Parse JSON request body
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            
            JSONObject jsonRequest = new JSONObject(buffer.toString());
            
            // Extrage parametrii din JSON
            int idSediu = jsonRequest.getInt("idSediu");
            String strada = jsonRequest.getString("strada");
            String cod = jsonRequest.getString("cod");
            String judet = jsonRequest.getString("judet");
            String oras = jsonRequest.getString("oras");
            String tara = jsonRequest.getString("tara");
            double latitudine = jsonRequest.getDouble("latitudine");
            double longitudine = jsonRequest.getDouble("longitudine");
            
            // Validare date
            if (strada.isEmpty() || cod.isEmpty() || judet.isEmpty() || 
                oras.isEmpty() || tara.isEmpty()) {
                response.setStatus(400);
                out.println("{\"error\":\"Toate câmpurile sunt obligatorii\"}");
                return;
            }
            
            // Actualizare în baza de date
            boolean success = updateSediuLocation(idSediu, strada, cod, judet, oras, tara, latitudine, longitudine);
            
            if (success) {
                out.println("{\"success\":true,\"message\":\"Locația sediului a fost actualizată cu succes\"}");
            } else {
                response.setStatus(500);
                out.println("{\"error\":\"Eroare la actualizarea locației sediului\"}");
            }
            
        } catch (Exception e) {
            response.setStatus(500);
            out.println("{\"error\":\"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Metoda pentru actualizarea locației sediului în baza de date
     */
    private boolean updateSediuLocation(int idSediu, String strada, String cod, String judet, 
                                      String oras, String tara, double latitudine, double longitudine) 
                                      throws SQLException, ClassNotFoundException {
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        String sql = "UPDATE sedii SET strada = ?, cod = ?, judet = ?, oras = ?, " +
                     "tara = ?, latitudine = ?, longitudine = ? WHERE id_sediu = ?";
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, strada);
            stmt.setString(2, cod);
            stmt.setString(3, judet);
            stmt.setString(4, oras);
            stmt.setString(5, tara);
            stmt.setDouble(6, latitudine);
            stmt.setDouble(7, longitudine);
            stmt.setInt(8, idSediu);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
}