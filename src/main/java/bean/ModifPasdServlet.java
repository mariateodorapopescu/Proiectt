package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ModifPasdServlet extends HttpServlet {
    private ModifPasdDao employeeDao;

    public void init() {
        employeeDao = new ModifPasdDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String password = request.getParameter("password");

        // Validate password
        if (!PasswordValidator.validatePassword(password)) {
            response.sendRedirect("modifpasd2.jsp?p=true");
            return;
        }

        // Fetch username from the database using the ID
        String username = fetchUsernameById(id);
        // System.out.println(username);
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Update password in database
        try {
            employeeDao.registerEmployee(password, username);
            response.sendRedirect("adminok.jsp"); // Redirect to a confirmation page
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp"); // Redirect to an error page
        }
    }

    private String fetchUsernameById(int userId) {
        String username = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT username FROM useri WHERE id = ?")) {
                preparedStatement.setInt(1, userId);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        username = rs.getString("username");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return username;
    }
}
