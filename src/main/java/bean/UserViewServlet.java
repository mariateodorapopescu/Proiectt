package bean;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.sql.DataSource;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/view1")
public class UserViewServlet extends HttpServlet {

    @Resource(name="jdbc/Proiect") // For Tomcat, define as <Resource> in context.xml and declare as <resource-ref> in web.xml.
    private DataSource dataSource;
    private UserDao productDAO;

    @Override
    public void init() {
        productDAO = new UserDao(dataSource);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<UserView> products = productDAO.list();
            request.setAttribute("products", products);
            request.getRequestDispatcher("/WEB-INF/products.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace(); // Log the complete stack trace
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/error.jsp").forward(request, response); // Forward to an error page
        }
    }
}