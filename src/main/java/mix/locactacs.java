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


public class locactacs extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public locactacs() {
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
            String query = "SELECT l.id_locatie as id, l.nume, l.longitudine, l.latitudine " +
                           "FROM locatii_atractii l;";

            preparedStatement = connection.prepareStatement(query);
            resultSet = preparedStatement.executeQuery();

            // 3. Construiesc un JSONArray cu informații despre departamente
            JSONArray locatii = new JSONArray();

            while (resultSet.next()) {
                // Creez un obiect JSON pentru fiecare rând
                JSONObject locatie = new JSONObject();
                locatie.put("id", resultSet.getString("id"));
                locatie.put("nume", resultSet.getString("nume"));
                locatie.put("longitude", resultSet.getDouble("longitudine"));
                locatie.put("latitude", resultSet.getDouble("latitudine"));

                // Adaug obiectul în JSONArray
                locatii.put(locatie);
            }

            // 4. Trimit răspunsul JSON
            out.print(locatii.toString());
            out.flush();

        } catch (Exception e) {
            // În caz de eroare, loghez și returnez un mesaj
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Eroare la încărcarea atractiilor turistice\"}");
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
