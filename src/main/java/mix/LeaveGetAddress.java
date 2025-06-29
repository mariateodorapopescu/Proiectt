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

public class LeaveGetAddress extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LeaveGetAddress() {
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
        String id = request.getParameter("id");

        try {
            // Conectare la baza de date
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");

            // Interogare pentru a obține localitățile unice din tabelul locatii_useri
            //String query = "SELECT DISTINCT oras FROM locatii_concedii";
            String query = "SELECT DISTINCT l.oras, l.judet FROM locatii_useri l " +
            		"join useri u on u.id=l.id_user " +
            		"where u.id_dep = " + id + " " + 
            		"ORDER BY l.oras;";
            preparedStatement = connection.prepareStatement(query);
            resultSet = preparedStatement.executeQuery();

            ArrayList<String> locations = new ArrayList<>();
            while (resultSet.next()) {
                //locations.add(resultSet.getString("oras"));
            	String oras = resultSet.getString("oras");
                String judet = resultSet.getString("judet");
                locations.add(oras + ", " + judet);
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
