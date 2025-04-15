package mix;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.json.JSONArray;
import org.json.JSONObject;

public class GetVacationDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public GetVacationDetailsServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            // Conectare la baza de date
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");

            String query = "SELECT culoare, strada, oras, judet, nume, prenume, nume_dep FROM locatii_concedii " +
                          "JOIN concedii ON locatii_concedii.id_concediu = concedii.id " +
                          "JOIN useri ON useri.id = concedii.id_ang " +
                          "JOIN departament ON useri.id_dep = departament.id_dep " +
                          "ORDER BY oras";
            
            preparedStatement = connection.prepareStatement(query);
            resultSet = preparedStatement.executeQuery();

            JSONArray jsonArray = new JSONArray();

            while (resultSet.next()) {
                JSONObject jsonObject = new JSONObject();
                
                String culoare = resultSet.getString("culoare");
                String strada = resultSet.getString("strada");
                String oras = resultSet.getString("oras");
                String judet = resultSet.getString("judet");
                String nume = resultSet.getString("nume");
                String prenume = resultSet.getString("prenume");
                String departament = resultSet.getString("nume_dep");
                
                // Setează informațiile în obiectul JSON
                jsonObject.put("color", culoare);
                jsonObject.put("street", strada);
                jsonObject.put("city", oras);
                jsonObject.put("county", judet);
                jsonObject.put("nume", nume);
                jsonObject.put("prenume", prenume);
                jsonObject.put("departament", departament);
                
                // Creează adresa completă pentru afișare și geocodificare
                String address = strada + ", " + oras + ", " + judet;
                jsonObject.put("address", address);
                
                // Text pentru popup
                String popupText = "Concediul angajatului " + nume + " " + prenume + " din departamentul " + departament + " este la adresa " + address;
                jsonObject.put("popupText", popupText);
                
                jsonArray.put(jsonObject);
            }

            out.print(jsonArray.toString());
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "Eroare la incarcarea localitatilor: " + e.getMessage());
            out.print(error.toString());
        } finally {
            try {
                if (resultSet != null) resultSet.close();
                if (preparedStatement != null) preparedStatement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}