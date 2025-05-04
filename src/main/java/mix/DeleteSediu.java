package mix;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class DeleteSediu extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Configurarea bazei de date
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idSediuStr = request.getParameter("id_sediu");
        
        if (idSediuStr == null || idSediuStr.isEmpty()) {
            response.sendRedirect("ListaSedii.jsp?status=error&message=ID-ul sediului lipsește");
            return;
        }
        
        try {
            int idSediu = Integer.parseInt(idSediuStr);
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                // Verificăm mai întâi dacă sediul este utilizat în alte tabele
                // Verificăm useri
                PreparedStatement checkUsersStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM useri WHERE id_sediu = ?"
                );
                checkUsersStmt.setInt(1, idSediu);
                ResultSet rsUsers = checkUsersStmt.executeQuery();
                rsUsers.next();
                int userCount = rsUsers.getInt(1);
                rsUsers.close();
                checkUsersStmt.close();
                
                // Verificăm locatii_useri
                PreparedStatement checkLocationsStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM locatii_useri WHERE id_sediu = ?"
                );
                checkLocationsStmt.setInt(1, idSediu);
                ResultSet rsLocations = checkLocationsStmt.executeQuery();
                rsLocations.next();
                int locationCount = rsLocations.getInt(1);
                rsLocations.close();
                checkLocationsStmt.close();
                
                if (userCount > 0 || locationCount > 0) {
                    // Sediul este utilizat, nu putem șterge
                    response.sendRedirect("ListaSedii.jsp?status=error&message=Sediul nu poate fi șters deoarece este utilizat de " + 
                                         userCount + " angajați și " + locationCount + " locații.");
                    return;
                }
                
                // Dacă sediul nu este utilizat, îl putem șterge
                PreparedStatement deleteStmt = conn.prepareStatement(
                    "DELETE FROM sedii WHERE id_sediu = ?"
                );
                deleteStmt.setInt(1, idSediu);
                
                int rowsAffected = deleteStmt.executeUpdate();
                deleteStmt.close();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("ListaSedii.jsp?status=success&message=Sediul a fost șters cu succes");
                } else {
                    response.sendRedirect("ListaSedii.jsp?status=error&message=Sediul cu ID-ul specificat nu a fost găsit");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("ListaSedii.jsp?status=error&message=ID-ul sediului nu este valid");
        } catch (Exception e) {
            System.err.println("Eroare la ștergerea sediului: " + e.getMessage());
            response.sendRedirect("ListaSedii.jsp?status=error&message=Eroare la ștergerea sediului: " + e.getMessage());
        }
    }
}