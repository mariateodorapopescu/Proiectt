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

@WebServlet("/ServletUpdateAddress")
public class ServletUpdateAddress extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        System.out.println("A primit cererea POST");

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
            System.out.println("JSON parsare reușită: " + json);
        } catch (Exception e) {
            System.err.println("Eroare la parsarea JSON: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Datele JSON sunt invalide.");
            return;
        }

        // Extrage parametrii din JSON
        String userId = json.optString("userId", "");
        String address = json.optString("address", "");

        if (userId.isEmpty() || address.isEmpty()) {
            System.err.println("Parametrii lipsesc sau sunt invalizi: userId=" + userId + ", address=" + address);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Eroare: Parametrii lipsesc sau sunt invalizi.");
            return;
        }

        // Conectare la baza de date și actualizare adresă
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stmt = conn.prepareStatement("UPDATE useri SET adresa = ? WHERE id = ?")) {

            stmt.setString(1, address);
            stmt.setString(2, userId);
            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                System.out.println("Adresa actualizată cu succes pentru utilizatorul cu ID-ul: " + userId);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Adresa a fost actualizată cu succes.");
            } else {
                System.err.println("Utilizatorul cu ID-ul " + userId + " nu a fost găsit.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Utilizatorul specificat nu a fost găsit.");
            }
        } catch (Exception e) {
            System.err.println("Eroare la actualizarea adresei în baza de date: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la actualizarea adresei.");
        }
    }
}