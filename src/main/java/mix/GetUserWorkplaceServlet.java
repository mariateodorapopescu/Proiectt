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
 * Servlet pentru preluarea informațiilor despre locurile de muncă ale unui utilizator
 */
public class GetUserWorkplaceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * Constructor
     */
    public GetUserWorkplaceServlet() {
        super();
    }
    
    /**
     * Metoda GET - returnează datele despre locurile de muncă ale utilizatorului în format JSON
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Preluăm parametrii
        int userId = -1;
        int departmentId = -1;
        int sediuId = -1;
        
        try {
            userId = Integer.parseInt(request.getParameter("id"));
            departmentId = Integer.parseInt(request.getParameter("id_dep"));
            
            // Sediul poate fi null
            String sediuParam = request.getParameter("id_sediu");
            if (sediuParam != null && !sediuParam.isEmpty() && !sediuParam.equals("null")) {
                sediuId = Integer.parseInt(sediuParam);
            }
        } catch (NumberFormatException e) {
            // Dacă parametrii lipsesc sau nu sunt numere, trimitem eroare
            JSONObject error = new JSONObject();
            error.put("error", "Parametri invalizi sau lipsă.");
            out.print(error.toString());
            return;
        }
        
        JSONArray workplacesArray = new JSONArray();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                
                // 1. Mai întâi verificăm sediul asociat utilizatorului (dacă există)
                if (sediuId > 0) {
                    String sediuQuery = "SELECT s.*, 'sediu' as type FROM sedii s WHERE s.id_sediu = ?";
                    
                    try (PreparedStatement sediuStatement = connection.prepareStatement(sediuQuery)) {
                        sediuStatement.setInt(1, sediuId);
                        
                        try (ResultSet rs = sediuStatement.executeQuery()) {
                            if (rs.next()) {
                                JSONObject workplace = new JSONObject();
                                
                                // Adăugăm informațiile despre sediu
                                workplace.put("type", "sediu");
                                workplace.put("id_sediu", rs.getInt("id_sediu"));
                                workplace.put("nume_sediu", rs.getString("nume_sediu"));
                                workplace.put("tip_sediu", rs.getString("tip_sediu"));
                                workplace.put("strada", rs.getString("strada"));
                                workplace.put("cod", rs.getString("cod"));
                                workplace.put("oras", rs.getString("oras"));
                                workplace.put("judet", rs.getString("judet"));
                                workplace.put("tara", rs.getString("tara"));
                                workplace.put("telefon", rs.getString("telefon"));
                                workplace.put("email", rs.getString("email"));
                                workplace.put("longitudine", rs.getDouble("longitudine"));
                                workplace.put("latitudine", rs.getDouble("latitudine"));
                                
                                // Adăugăm locul de muncă în array-ul JSON
                                workplacesArray.put(workplace);
                            }
                        }
                    }
                }
                
                // 2. Adăugăm locația departamentului utilizatorului
                String depQuery = "SELECT ld.*, d.nume_dep, 'departament' as type " +
                                 "FROM locatii_departamente ld " +
                                 "JOIN departament d ON ld.id_dep = d.id_dep " +
                                 "WHERE ld.id_dep = ? AND ld.longitudine IS NOT NULL AND ld.latitudine IS NOT NULL";
                
                try (PreparedStatement depStatement = connection.prepareStatement(depQuery)) {
                    depStatement.setInt(1, departmentId);
                    
                    try (ResultSet rs = depStatement.executeQuery()) {
                        if (rs.next()) {
                            JSONObject workplace = new JSONObject();
                            
                            // Adăugăm informațiile despre departament
                            workplace.put("type", "departament");
                            workplace.put("id_dep", rs.getInt("id_dep"));
                            workplace.put("nume_dep", rs.getString("nume_dep"));
                            workplace.put("strada", rs.getString("strada"));
                            workplace.put("cod", rs.getString("cod"));
                            workplace.put("oras", rs.getString("oras"));
                            workplace.put("judet", rs.getString("judet"));
                            workplace.put("tara", rs.getString("tara"));
                            workplace.put("longitudine", rs.getDouble("longitudine"));
                            workplace.put("latitudine", rs.getDouble("latitudine"));
                            
                            // Adăugăm locul de muncă în array-ul JSON
                            workplacesArray.put(workplace);
                        }
                    }
                }
                
                // 3. Verificăm dacă există locații specifice pentru utilizator
                String userLocQuery = "SELECT lu.*, 'user' as type " +
                                    "FROM locatii_useri lu " +
                                    "WHERE lu.id_user = ? AND lu.longitudine IS NOT NULL AND lu.latitudine IS NOT NULL";
                
                try (PreparedStatement userLocStatement = connection.prepareStatement(userLocQuery)) {
                    userLocStatement.setInt(1, userId);
                    
                    try (ResultSet rs = userLocStatement.executeQuery()) {
                        while (rs.next()) {
                            JSONObject workplace = new JSONObject();
                            
                            // Adăugăm informațiile despre locația utilizatorului
                            workplace.put("type", "user");
                            workplace.put("id_locatie", rs.getInt("id_locatie"));
                            workplace.put("strada", rs.getString("strada"));
                            workplace.put("cod", rs.getString("cod"));
                            workplace.put("oras", rs.getString("oras"));
                            workplace.put("judet", rs.getString("judet"));
                            workplace.put("tara", rs.getString("tara"));
                            workplace.put("longitudine", rs.getDouble("longitudine"));
                            workplace.put("latitudine", rs.getDouble("latitudine"));
                            
                            // Verificăm dacă există un sediu asociat
                            if (rs.getObject("id_sediu") != null) {
                                int locSediuId = rs.getInt("id_sediu");
                                
                                // Căutăm informații despre sediu
                                String sediuInfoQuery = "SELECT nume_sediu, tip_sediu FROM sedii WHERE id_sediu = ?";
                                try (PreparedStatement sediuInfoStatement = connection.prepareStatement(sediuInfoQuery)) {
                                    sediuInfoStatement.setInt(1, locSediuId);
                                    
                                    try (ResultSet sediuRs = sediuInfoStatement.executeQuery()) {
                                        if (sediuRs.next()) {
                                            workplace.put("id_sediu", locSediuId);
                                            workplace.put("nume_sediu", sediuRs.getString("nume_sediu"));
                                            workplace.put("tip_sediu", sediuRs.getString("tip_sediu"));
                                        }
                                    }
                                }
                            }
                            
                            // Adăugăm locul de muncă în array-ul JSON
                            workplacesArray.put(workplace);
                        }
                    }
                }
                
                // 4. Dacă nu am găsit nicio locație, adăugăm toate sediile disponibile
                if (workplacesArray.length() == 0) {
                    String allSediiQuery = "SELECT s.*, 'sediu' as type FROM sedii s " +
                                         "WHERE s.longitudine IS NOT NULL AND s.latitudine IS NOT NULL " +
                                         "ORDER BY s.tip_sediu, s.nume_sediu";
                    
                    try (PreparedStatement allSediiStatement = connection.prepareStatement(allSediiQuery)) {
                        try (ResultSet rs = allSediiStatement.executeQuery()) {
                            while (rs.next()) {
                                JSONObject workplace = new JSONObject();
                                
                                // Adăugăm informațiile despre sediu
                                workplace.put("type", "sediu");
                                workplace.put("id_sediu", rs.getInt("id_sediu"));
                                workplace.put("nume_sediu", rs.getString("nume_sediu"));
                                workplace.put("tip_sediu", rs.getString("tip_sediu"));
                                workplace.put("strada", rs.getString("strada"));
                                workplace.put("cod", rs.getString("cod"));
                                workplace.put("oras", rs.getString("oras"));
                                workplace.put("judet", rs.getString("judet"));
                                workplace.put("tara", rs.getString("tara"));
                                workplace.put("telefon", rs.getString("telefon"));
                                workplace.put("email", rs.getString("email"));
                                workplace.put("longitudine", rs.getDouble("longitudine"));
                                workplace.put("latitudine", rs.getDouble("latitudine"));
                                
                                // Adăugăm locul de muncă în array-ul JSON
                                workplacesArray.put(workplace);
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
            
            // Trimitem array-ul JSON către client
            out.print(workplacesArray.toString());
            
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