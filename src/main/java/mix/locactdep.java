package mix;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;


public class locactdep extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public locactdep() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
                         throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            // 1. Încărc driverul și creez conexiunea
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", 
                "root", 
                "student"
            );

            // 2. Scriu interogarea
            String query = "SELECT d.id_dep, d.nume_dep, l.longitudine, l.latitudine " +
                           "FROM departament d " +
                           "JOIN locatii_departamente l ON d.id_dep = l.id_dep " +
                           "ORDER BY d.nume_dep";

            preparedStatement = connection.prepareStatement(query);
            resultSet = preparedStatement.executeQuery();

            // 3. Construiesc un JSONArray cu informații despre departamente
            JSONArray departments = new JSONArray();

            while (resultSet.next()) {
                // Creez un obiect JSON pentru fiecare rând
                JSONObject department = new JSONObject();
                department.put("id_dep", resultSet.getInt("id_dep"));
                department.put("nume_dep", resultSet.getString("nume_dep"));
                department.put("longitude", resultSet.getDouble("longitudine"));
                department.put("latitude", resultSet.getDouble("latitudine"));

                // Adaug obiectul în JSONArray
                departments.put(department);
            }

            // 4. Trimit răspunsul JSON
            out.print(departments.toString());
            out.flush();

        } catch (Exception e) {
            // În caz de eroare, loghez și returnez un mesaj
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Eroare la încărcarea departamentelor\"}");
        } finally {
            // 5. Închid resursele
            try {
                if (resultSet != null) {
                    resultSet.close();
                }
                if (preparedStatement != null) {
                    preparedStatement.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
                          throws ServletException, IOException {
        // Redirectez POST către GET
        doGet(request, response);
    }
}
