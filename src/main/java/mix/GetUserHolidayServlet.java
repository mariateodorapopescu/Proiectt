package mix;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet pentru preluarea informațiilor despre concediile unui utilizator din baza de date
 */
public class GetUserHolidayServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * Constructor
     */
    public GetUserHolidayServlet() {
        super();
    }
    
    /**
     * Metoda GET - returnează datele despre concediile utilizatorului în format JSON
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
        
        JSONArray holidaysArray = new JSONArray();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                
                // Query pentru a extrage concediile utilizatorului 
                // cu datele de locație din tabela locatii_concedii
                String query = "SELECT c.*, lc.strada, lc.longitudine, lc.latitudine, lc.cod, lc.oras, " +
                               "lc.judet, lc.tara " +
                               "FROM concedii c " +
                               "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                               "WHERE c.id_ang = ? AND lc.longitudine IS NOT NULL AND lc.latitudine IS NOT NULL " +
                               "ORDER BY c.start_c DESC";
                
                try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
                    preparedStatement.setInt(1, userId);
                    
                    try (ResultSet rs = preparedStatement.executeQuery()) {
                        
                        while (rs.next()) {
                            JSONObject holiday = new JSONObject();
                            
                            // Adăugăm informațiile despre concediu
                            holiday.put("id", rs.getInt("id"));
                            holiday.put("start_c", rs.getString("start_c"));
                            holiday.put("end_c", rs.getString("end_c"));
                            holiday.put("motiv", rs.getString("motiv"));
                            holiday.put("locatie", rs.getString("locatie"));
                            holiday.put("status", rs.getInt("status"));
                            holiday.put("tip", rs.getInt("tip"));
                            holiday.put("durata", rs.getInt("durata"));
                            
                            // Adăugăm informațiile despre locație
                            if (rs.getString("strada") != null) {
                                holiday.put("strada", rs.getString("strada"));
                                holiday.put("cod", rs.getString("cod"));
                                holiday.put("oras", rs.getString("oras"));
                                holiday.put("judet", rs.getString("judet"));
                                holiday.put("tara", rs.getString("tara"));
                                holiday.put("longitudine", rs.getDouble("longitudine"));
                                holiday.put("latitudine", rs.getDouble("latitudine"));
                            }
                            
                            // Adăugăm concediul în array-ul JSON - folosim put() în loc de add()
                            holidaysArray.put(holiday);
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
            
            // Trimitem array-ul JSON către client
            out.print(holidaysArray.toString());
            
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