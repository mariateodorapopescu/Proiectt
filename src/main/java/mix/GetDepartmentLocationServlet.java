package mix;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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

@WebServlet("/GetDepartmentLocationServlet")
public class GetDepartmentLocationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter();
             Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(
                 "SELECT d.id_dep, d.nume_dep, l.longitudine, l.latitudine FROM departament d " +
                 "JOIN locatii_departamente l ON d.id_dep = l.id_dep ORDER BY d.nume_dep"
             );
             ResultSet resultSet = preparedStatement.executeQuery()
        ) {
            JSONArray departments = new JSONArray();
            while (resultSet.next()) {
                JSONObject department = new JSONObject();
                department.put("id_dep", resultSet.getInt("id_dep"));
                department.put("nume_dep", resultSet.getString("nume_dep"));
                department.put("longitude", resultSet.getDouble("longitudine"));
                department.put("latitude", resultSet.getDouble("latitudine"));
                departments.put(department);
            }
            out.print(departments.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Eroare la încărcarea departamentelor\"}");
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
