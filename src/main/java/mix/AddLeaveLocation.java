package mix;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class AddLeaveLocation extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Citește corpul cererii o singură dată
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String rawJson = sb.toString();

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
        int idCon = json.optInt("id_con");
        String strada = json.optString("strada", "");
        double latitudine = json.optDouble("latitudine");
        double longitudine = json.optDouble("longitudine");
        String cod = json.optString("cod", "");
        String oras = json.optString("oras", "");
        String judet = json.optString("judet", "");
        String tara = json.optString("tara", "");

        if (idCon == 0) {
            System.err.println("Parametrul idDep lipsește sau este invalid: idCon=" + idCon);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Parametrul idDep lipsește sau este invalid.");
            return;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            
            // Verifică dacă există deja o înregistrare pentru acest id_dep
            boolean exists = false;
            try (PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT 1 FROM locatii_concedii WHERE id_concediu = ?")) {
                checkStmt.setInt(1, idCon);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    exists = rs.next();
                }
            }

            PreparedStatement stmt;
            if (exists) {
                // Update existing record
                stmt = conn.prepareStatement(
                    "UPDATE locatii_concedii SET strada = ?, longitudine = ?, latitudine = ?, " +
                    "cod = ?, oras = ?, judet = ?, tara = ? WHERE id_concediu = ?");
                
                stmt.setString(1, strada);
                stmt.setDouble(2, longitudine);
                stmt.setDouble(3, latitudine);
                stmt.setString(4, cod);
                stmt.setString(5, oras);
                stmt.setString(6, judet);
                stmt.setString(7, tara);
                stmt.setInt(8, idCon);
            } else {
                // Insert new record
                stmt = conn.prepareStatement(
                    "INSERT INTO locatii_concedii (id_concediu, strada, longitudine, latitudine, " +
                    "cod, oras, judet, tara) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                
                stmt.setInt(1, idCon);
                stmt.setString(2, strada);
                stmt.setDouble(3, longitudine);
                stmt.setDouble(4, latitudine);
                stmt.setString(5, cod);
                stmt.setString(6, oras);
                stmt.setString(7, judet);
                stmt.setString(8, tara);
            }

            int rowsAffected = stmt.executeUpdate();
            stmt.close();

            if (rowsAffected > 0) {
                // System.out.println("Operațiune reușită pentru departamentul cu ID-ul: " + idCon);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Operațiunea a fost efectuată cu succes.");
            } else {
                System.err.println("Nu s-a putut efectua operațiunea pentru departamentul cu ID-ul " + idCon);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Nu s-a putut efectua operațiunea.");
            }

        } catch (Exception e) {
            System.err.println("Eroare la operațiunea în baza de date: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la operațiunea în baza de date.");
        }
    }
}