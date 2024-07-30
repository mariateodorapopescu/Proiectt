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
public class DelDepServlet extends HttpServlet {
    private DelDepDao employeeDao;

    public void init() throws ServletException {
        try {
            employeeDao = new DelDepDao();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DelUsrDao", e);
        }
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { 
    	doPost(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        if (username == null) {
        	 response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
 		    out.println("<script type='text/javascript'>");
 		    out.println("alert('Nu e nimeni logat?!');");
 		    out.println("window.location.href = 'modifdeldep.jsp';");
 		    out.println("</script>");
 		    out.close();
        }
        int id = fetchId(username);
        try {
            employeeDao.deleteUser(username, id);
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge departamentul din motive necunoscute.');");
		    out.println("window.location.href = 'modifdeldep.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    public int fetchId(String username) {
        int id = -1;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id_dep FROM departament WHERE nume_dep = ?")) {
                preparedStatement.setString(1, username);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        id = rs.getInt("id_dep");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return id;
    }

    
}
