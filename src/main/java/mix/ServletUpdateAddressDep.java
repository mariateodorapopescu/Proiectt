 package mix;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class ServletUpdateAddressDep extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        System.out.println("A primit cererea POST pentru departamente");

        // Citește corpul cererii o singură dată
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
            System.out.println("JSON parsare reusita: " + json);
        } catch (Exception e) {
            System.err.println("Eroare la parsarea JSON: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Datele JSON sunt invalide.");
            return;
        }

        // Extrage parametrii din JSON
        String departmentId = json.optString("departmentId", "");
        String address = json.optString("address", "");

        if (departmentId.isEmpty() || address.isEmpty()) {
            System.err.println("Parametrii lipsesc sau sunt invalizi: departmentId=" + departmentId + ", address=" + address);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Parametrii lipsesc sau sunt invalizi.");
            return;
        }

        // Conectare la baza de date și actualizare adresă
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stmt = conn.prepareStatement("UPDATE departamente SET adresa = ? WHERE id_dep = ?")) {

            stmt.setString(1, address);
            stmt.setString(2, departmentId);
            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                System.out.println("Adresa actualizata cu succes pentru departamentul cu ID-ul: " + departmentId);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Adresa a fost actualizata cu succes.");
            } else {
                System.err.println("Departamentul cu ID-ul " + departmentId + " nu a fost gasit.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Departamentul specificat nu a fost gasit.");
            }
        } catch (Exception e) {
            System.err.println("Eroare la actualizarea adresei in baza de date: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la actualizarea adresei.");
        }
    }
}
