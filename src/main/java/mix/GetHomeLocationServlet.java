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
import org.json.JSONObject;

@WebServlet("/GetHomeLocationServlet")
public class GetHomeLocationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String userId = (String) request.getSession().getAttribute("id_user");

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"ID-ul utilizatorului nu este setat\"}");
            return;
        }

        try (PrintWriter out = response.getWriter();
             Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(
                 "SELECT oras, judet, latitudine, longitudine FROM locatii_useri WHERE id_user = ?"
             )
        ) {
            preparedStatement.setString(1, userId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                JSONObject location = new JSONObject();

                if (resultSet.next()) {
                    location.put("latitude", resultSet.getDouble("latitudine"));
                    location.put("longitude", resultSet.getDouble("longitudine"));
                    location.put("address", resultSet.getString("oras") + ", " + resultSet.getString("judet"));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Locația nu a fost găsită pentru utilizatorul dat\"}");
                    return;
                }

                out.print(location.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Eroare la încărcarea locației de acasă\"}");
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}