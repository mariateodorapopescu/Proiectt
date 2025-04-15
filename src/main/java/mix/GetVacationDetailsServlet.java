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
import java.util.ArrayList;
import org.json.JSONArray;

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

            // Interogare pentru a obține localitățile unice din tabelul locatii_useri
            //String query = "SELECT DISTINCT oras FROM locatii_concedii";
            String query = "SELECT culoare, strada, oras, judet, nume, prenume, nume_dep FROM locatii_concedii join concedii on locatii_concedii.id_concediu = concedii.id join useri on useri.id = concedii.id_ang join departament on useri.id_dep = departament.id_dep ORDER BY oras;";
            preparedStatement = connection.prepareStatement(query);
            resultSet = preparedStatement.executeQuery();

            ArrayList<String> locations = new ArrayList<>();
            while (resultSet.next()) {
                //locations.add(resultSet.getString("oras"));
            	String culoare = resultSet.getString("culoare");
            	String strada = resultSet.getString("strada");
            	String oras = resultSet.getString("oras");
                String judet = resultSet.getString("judet");
                String nume = resultSet.getString("nume"); // tre sa fac un join......
                String prenume = resultSet.getString("prenume");
                String departament = resultSet.getString("nume_dep");
                locations.add("Concediul angajatului " + nume + " " + prenume + " din departamentul " + departament + " este la adresa " + strada + ", " + oras + ", " + judet);
            }

            // Conversie a listei în JSON și trimitere ca răspuns
            JSONArray jsonArray = new JSONArray(locations);
            out.print(jsonArray.toString());
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Eroare la incarcarea localitatilor\"}");
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