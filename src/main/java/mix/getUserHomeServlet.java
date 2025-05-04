package mix;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

/**
 * Servlet pentru preluarea informațiilor despre adresa de acasă a unui utilizator
 */
public class getUserHomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * Constructor
     */
    public getUserHomeServlet() {
        super();
    }
    
    /**
     * Metoda GET - returnează datele despre adresa de acasă a utilizatorului în format JSON
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        int userId = -1;
        try {
            userId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            // Dacă parametrul id lipsește sau nu este un număr, trimitem eroare
            JSONObject error = new JSONObject();
            error.put("error", "ID utilizator invalid sau lipsă.");
            out.print(error.toString());
            return;
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                
                // Query pentru a extrage adresa de acasă a utilizatorului din tabela locatii_useri
                String query = "SELECT lu.strada, lu.longitudine, lu.latitudine, lu.cod, lu.oras, " +
                               "lu.judet, lu.tara, lu.id_sediu, s.nume_sediu " +
                               "FROM locatii_useri lu " +
                               "LEFT JOIN sedii s ON lu.id_sediu = s.id_sediu " +
                               "WHERE lu.id_user = ? AND lu.longitudine IS NOT NULL AND lu.latitudine IS NOT NULL";
                
                try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
                    preparedStatement.setInt(1, userId);
                    
                    try (ResultSet rs = preparedStatement.executeQuery()) {
                        JSONObject homeAddress = new JSONObject();
                        
                        if (rs.next()) {
                            // Adăugăm informațiile despre adresa de acasă
                            homeAddress.put("strada", rs.getString("strada"));
                            homeAddress.put("cod", rs.getString("cod"));
                            homeAddress.put("oras", rs.getString("oras"));
                            homeAddress.put("judet", rs.getString("judet"));
                            homeAddress.put("tara", rs.getString("tara"));
                            homeAddress.put("longitudine", rs.getDouble("longitudine"));
                            homeAddress.put("latitudine", rs.getDouble("latitudine"));
                            
                            // Adăugăm informații despre sediul asociat, dacă există
                            if (rs.getObject("id_sediu") != null) {
                                homeAddress.put("id_sediu", rs.getInt("id_sediu"));
                                homeAddress.put("nume_sediu", rs.getString("nume_sediu"));
                            }
                            
                            // Trimitem JSON-ul către client
                            out.print(homeAddress.toString());
                        } else {
                            // În cazul în care nu găsim o adresă pentru utilizator, căutăm în departament
                            String queryDep = "SELECT d.id_dep, ld.strada, ld.longitudine, ld.latitudine, ld.cod, " +
                                            "ld.oras, ld.judet, ld.tara " +
                                            "FROM useri u " +
                                            "JOIN departament d ON u.id_dep = d.id_dep " +
                                            "JOIN locatii_departamente ld ON d.id_dep = ld.id_dep " +
                                            "WHERE u.id = ? AND ld.longitudine IS NOT NULL AND ld.latitudine IS NOT NULL";
                            
                            try (PreparedStatement depStatement = connection.prepareStatement(queryDep)) {
                                depStatement.setInt(1, userId);
                                
                                try (ResultSet depRs = depStatement.executeQuery()) {
                                    if (depRs.next()) {
                                        // Adăugăm informațiile despre adresa departamentului ca backup
                                        homeAddress.put("strada", depRs.getString("strada"));
                                        homeAddress.put("cod", depRs.getString("cod"));
                                        homeAddress.put("oras", depRs.getString("oras"));
                                        homeAddress.put("judet", depRs.getString("judet"));
                                        homeAddress.put("tara", depRs.getString("tara"));
                                        homeAddress.put("longitudine", depRs.getDouble("longitudine"));
                                        homeAddress.put("latitudine", depRs.getDouble("latitudine"));
                                        homeAddress.put("info", "Adresă departament (nu s-a găsit adresa personală)");
                                        
                                        // Trimitem JSON-ul către client
                                        out.print(homeAddress.toString());
                                    } else {
                                        // În cazul în care nu găsim nicio adresă, trimitem un obiect gol
                                        homeAddress.put("error", "Nu s-a găsit nicio adresă pentru utilizator.");
                                        out.print(homeAddress.toString());
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                JSONObject error = new JSONObject();
                error.put("error", "Eroare la baza de date: " + e.getMessage());
                out.print(error.toString());
                e.printStackTrace();
                return;
            }
            
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("error", "Eroare generală: " + e.getMessage());
            out.print(error.toString());
            e.printStackTrace();
        }
    }
    
    /**
     * Metoda POST - redirecționează către metoda GET
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}