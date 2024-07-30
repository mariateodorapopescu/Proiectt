package bean;

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
import java.sql.SQLException;

//@WebServlet("/delusr")
public class DelUsrServlet extends HttpServlet {
    private DelUsrDao employeeDao;

    public void init() throws ServletException {
        try {
            employeeDao = new DelUsrDao();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DeldDao", e);
        }
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doPost(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	int id = Integer.parseInt(request.getParameter("id"));
    	String username = fetchUsernameById(id);
        if (username == null) {
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu se stie cine sa fie sters');");
 		    out.println("window.location.href = 'modifdel.jsp';");
 		    out.println("</script>");
 		    out.close();
        }

        try {
            employeeDao.deleteUser(username, id);
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge utilizatorul din motive necunoscute.');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
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
