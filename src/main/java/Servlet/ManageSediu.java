package Servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class ManageSediu extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Configurarea bazei de date
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";
    
    // Initialize the JDBC driver in init() method
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver Registered!");
        } catch (ClassNotFoundException e) {
            System.out.println("Error: MySQL JDBC Driver not found!");
            e.printStackTrace();
            throw new ServletException("JDBC Driver not found", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Obține detaliile sediului pentru editare
        String idSediuStr = request.getParameter("id_sediu");
        
        if (idSediuStr == null || idSediuStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("ID-ul sediului lipsește");
            return;
        }
        
        try {
            int idSediu = Integer.parseInt(idSediuStr);
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                PreparedStatement stmt = conn.prepareStatement(
                    "SELECT * FROM sedii WHERE id_sediu = ?"
                );
                stmt.setInt(1, idSediu);
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    JSONObject jsonResponse = new JSONObject();
                    jsonResponse.put("id_sediu", rs.getInt("id_sediu"));
                    jsonResponse.put("nume_sediu", rs.getString("nume_sediu"));
                    jsonResponse.put("tip_sediu", rs.getString("tip_sediu"));
                    jsonResponse.put("strada", rs.getString("strada"));
                    jsonResponse.put("cod", rs.getString("cod"));
                    jsonResponse.put("oras", rs.getString("oras"));
                    jsonResponse.put("judet", rs.getString("judet"));
                    jsonResponse.put("tara", rs.getString("tara"));
                    jsonResponse.put("telefon", rs.getString("telefon"));
                    jsonResponse.put("email", rs.getString("email"));
                    jsonResponse.put("latitudine", rs.getDouble("latitudine"));
                    jsonResponse.put("longitudine", rs.getDouble("longitudine"));
                    
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write(jsonResponse.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("Sediul cu ID-ul specificat nu a fost găsit");
                }
                
                rs.close();
                stmt.close();
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("ID-ul sediului nu este valid");
        } catch (Exception e) {
            System.err.println("Eroare la obținerea detaliilor sediului: " + e.getMessage());
            e.printStackTrace(); // Print the full stack trace for debugging
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la procesarea cererii: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("ManageSediu doPost called");
        
        // Citește corpul cererii
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String rawJson = sb.toString();
        System.out.println("Received data: " + rawJson);
        
        JSONObject json;
        try {
            json = new JSONObject(rawJson);
        } catch (Exception e) {
            System.err.println("Eroare la parsarea JSON: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Datele JSON sunt invalide.");
            return;
        }
        
        // Extrage parametrii din JSON
        int idSediu = json.optInt("id_sediu", 0);
        String numeSediu = json.optString("nume_sediu", "");
        String tipSediu = json.optString("tip_sediu", "");
        String strada = json.optString("strada", "");
        String cod = json.optString("cod", "");
        String oras = json.optString("oras", "");
        String judet = json.optString("judet", "");
        String tara = json.optString("tara", "");
        String telefon = json.optString("telefon", "");
        String email = json.optString("email", "");
        double latitudine = json.optDouble("latitudine", 0);
        double longitudine = json.optDouble("longitudine", 0);
        
        System.out.println("Processed data: id=" + idSediu + ", name=" + numeSediu);
        
        // Validează datele obligatorii
        if (numeSediu.isEmpty() || tipSediu.isEmpty() || strada.isEmpty() || 
            cod.isEmpty() || oras.isEmpty() || judet.isEmpty() || tara.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Câmpurile obligatorii nu sunt completate.");
            return;
        }
        
        try {
            // Încarcă explicit driver-ul JDBC
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                PreparedStatement stmt;
                boolean isUpdate = idSediu > 0;
                
                if (isUpdate) {
                    // Update existing record
                    System.out.println("Updating existing record with ID: " + idSediu);
                    stmt = conn.prepareStatement(
                        "UPDATE sedii SET nume_sediu = ?, tip_sediu = ?, strada = ?, cod = ?, " +
                        "oras = ?, judet = ?, tara = ?, telefon = ?, email = ?, latitudine = ?, " +
                        "longitudine = ?, data_modificare = CURRENT_TIMESTAMP WHERE id_sediu = ?"
                    );
                    
                    stmt.setString(1, numeSediu);
                    stmt.setString(2, tipSediu);
                    stmt.setString(3, strada);
                    stmt.setString(4, cod);
                    stmt.setString(5, oras);
                    stmt.setString(6, judet);
                    stmt.setString(7, tara);
                    stmt.setString(8, telefon);
                    stmt.setString(9, email);
                    stmt.setDouble(10, latitudine);
                    stmt.setDouble(11, longitudine);
                    stmt.setInt(12, idSediu);
                } else {
                    // Insert new record
                    System.out.println("Inserting new record");
                    stmt = conn.prepareStatement(
                        "INSERT INTO sedii (nume_sediu, tip_sediu, strada, cod, oras, judet, tara, " +
                        "telefon, email, latitudine, longitudine, data_creare) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)",
                        Statement.RETURN_GENERATED_KEYS
                    );
                    
                    stmt.setString(1, numeSediu);
                    stmt.setString(2, tipSediu);
                    stmt.setString(3, strada);
                    stmt.setString(4, cod);
                    stmt.setString(5, oras);
                    stmt.setString(6, judet);
                    stmt.setString(7, tara);
                    stmt.setString(8, telefon);
                    stmt.setString(9, email);
                    stmt.setDouble(10, latitudine);
                    stmt.setDouble(11, longitudine);
                }
                
                int rowsAffected = stmt.executeUpdate();
                System.out.println("Rows affected: " + rowsAffected);
                
                if (rowsAffected > 0) {
                    if (!isUpdate) {
                        // Obține ID-ul noului sediu
                        ResultSet generatedKeys = stmt.getGeneratedKeys();
                        if (generatedKeys.next()) {
                            idSediu = generatedKeys.getInt(1);
                        }
                        generatedKeys.close();
                    }
                    
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Operațiune reușită pentru sediul cu ID-ul: " + idSediu);
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("Nu s-a putut efectua operațiunea pentru sediu.");
                }
                
                stmt.close();
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Eroare la încărcarea driver-ului JDBC: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la încărcarea driver-ului JDBC: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Eroare la operațiunea în baza de date: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la operațiunea în baza de date: " + e.getMessage());
        }
    }
}