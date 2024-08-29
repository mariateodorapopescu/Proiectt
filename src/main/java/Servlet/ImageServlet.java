package Servlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import bean.MyUser;

public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            writeJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, "No session found.");
            return;
        }

        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            writeJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, "No user session found.");
            return;
        }

        String username = currentUser.getUsername();

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement statement = connection.prepareStatement("SELECT profil FROM useri WHERE username = ?")) {
            statement.setString(1, username);
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                byte[] imgData = rs.getBytes("profil");
                if (imgData != null) {
                    response.setContentType("image/jpeg");
                    response.setContentLength(imgData.length);
                    OutputStream os = response.getOutputStream();
                    os.write(imgData);
                    os.flush();
                    os.close();
                } else {
                    writeJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, "Image not found.");
                }
            } else {
                writeJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, "User not found.");
            }
        } catch (Exception e) {
            throw new ServletException("Database access error", e);
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setContentType("application/json");
        response.setStatus(statusCode);
        String json = "{\"status\":\"error\",\"message\":\"" + message + "\"}";
        response.getWriter().write(json);
    }
}