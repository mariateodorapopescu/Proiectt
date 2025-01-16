 package mix;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;


public class locatiee extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // 1. Citește JSON
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String rawJson = sb.toString();
        System.out.println("Raw JSON received: " + rawJson);

        JSONObject json;
        try {
            json = new JSONObject(rawJson);
            System.out.println("JSON parsare reușită: " + json);
        } catch (Exception e) {
            System.err.println("Eroare la parsarea JSON: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Datele JSON sunt invalide.");
            return;
        }

        // 2. Extrage parametrii așa cum îi trimite JS
        String userIdStr = json.optString("userId", "");
        String strada    = json.optString("strada", "");
        String oras      = json.optString("oras", "");
        String judet     = json.optString("judet", "");
        String cod       = json.optString("cod", "");
        String tara      = json.optString("tara", "");
        double latitudine  = json.optDouble("latitudine");
        double longitudine = json.optDouble("longitudine");

        // 3. Validare userId
        int idDep;
        try {
            idDep = Integer.parseInt(userIdStr);
        } catch (NumberFormatException e) {
            System.err.println("Eroare la conversia userId: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: userId invalid.");
            return;
        }

        if (idDep == 0) {
            System.err.println("Parametrul idDep lipsește sau este invalid: idDep=" + idDep);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Parametrul idDep lipsește sau este invalid.");
            return;
        }

        // 4. Conexiune la DB
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            
            // Verifică dacă există deja înregistrare
            boolean exists;
            try (PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT 1 FROM locatii_useri WHERE id_user = ?")) {
                checkStmt.setInt(1, idDep);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    exists = rs.next();
                }
            }

            // 5. Construiește query-ul (insert/update)
            PreparedStatement stmt;
            if (exists) {
                stmt = conn.prepareStatement(
                    "UPDATE locatii_useri SET strada=?, longitudine=?, latitudine=?, cod=?, oras=?, judet=?, tara=? " +
                    "WHERE id_user=?"
                );
                stmt.setString(1, strada);
                stmt.setDouble(2, longitudine);
                stmt.setDouble(3, latitudine);
                stmt.setString(4, cod);
                stmt.setString(5, oras);
                stmt.setString(6, judet);
                stmt.setString(7, tara);
                stmt.setInt(8, idDep);
            } else {
                stmt = conn.prepareStatement(
                    "INSERT INTO locatii_useri (id_user, strada, longitudine, latitudine, cod, oras, judet, tara) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                );
                stmt.setInt(1, idDep);
                stmt.setString(2, strada);
                stmt.setDouble(3, longitudine);
                stmt.setDouble(4, latitudine);
                stmt.setString(5, cod);
                stmt.setString(6, oras);
                stmt.setString(7, judet);
                stmt.setString(8, tara);
            }

            // 6. Execute
            int rowsAffected = stmt.executeUpdate();
            stmt.close();

            if (rowsAffected > 0) {
                System.out.println("Operațiune reușită pt user ID: " + idDep);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Operațiunea a fost efectuată cu succes.");
            } else {
                System.err.println("Nu s-a putut efectua operațiunea pt user ID: " + idDep);
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

