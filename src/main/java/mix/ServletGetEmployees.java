package mix;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Servlet implementation class ServletGetEmployees
 */
@WebServlet("/ServletGetEmployees")
public class ServletGetEmployees extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ServletGetEmployees() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        double maxDistance = Double.parseDouble(request.getParameter("distance")); 
        double userLatitude = 45.6556;
        double userLongitude = 25.2777; 

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT adresa " +
                     "(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance " +
                     "FROM useri HAVING distance <= ?")) {

            // Setăm parametrii interogării SQL
            stmt.setDouble(1, userLatitude);
            stmt.setDouble(2, userLongitude);
            stmt.setDouble(3, userLatitude);
            stmt.setDouble(4, maxDistance);

            ResultSet rs = stmt.executeQuery();
            JSONArray employees = new JSONArray();

            while (rs.next()) {
                JSONObject employee = new JSONObject();
                employee.put("id", rs.getInt("id"));
                employee.put("nume", rs.getString("nume"));
                employee.put("prenume", rs.getString("prenume"));
                employee.put("latitude", rs.getDouble("latitude"));
                employee.put("longitude", rs.getDouble("longitude"));
                employee.put("distance", rs.getDouble("distance"));
                employees.put(employee);
            }

            PrintWriter out = response.getWriter();
            out.write(employees.toString());
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
