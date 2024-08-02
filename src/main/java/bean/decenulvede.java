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
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class decenulvede
 */
public class decenulvede extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public decenulvede() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
		try {
	    	response.setContentType("application/json");
	    	response.setHeader("Access-Control-Allow-Origin", "*"); // For development only, specify domains in production
	    	response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
	    	response.setHeader("Access-Control-Allow-Headers", "Content-Type");

	        JSONArray events = new JSONArray();

	        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	             Statement statement = connection.createStatement();
	             ResultSet rs = statement.executeQuery("SELECT accent, nume, prenume, start_c, end_c FROM concedii join useri on concedii.id_ang = useri.id join teme on useri.id = teme.id_usr")) {

	            while (rs.next()) {
	                JSONObject event = new JSONObject();
	                event.put("title", rs.getString("nume") + rs.getString("prenume"));
	                event.put("start", rs.getDate("start_c").toString());
	                event.put("end", rs.getDate("end_c").toString());
	                event.put("color", rs.getString("accent")); // Example color
	                event.put("textColor", "white");
	                events.put(event);
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	            throw new ServletException("Eroare BD=(", e);
	        }
	        System.out.println(events);
	        PrintWriter out = response.getWriter();
	        out.print(events.toString());
	    }
	    catch (Exception e) {
	        e.printStackTrace(); // Log server-side exceptions
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	        response.getWriter().write("Internal Server Error: " + e.getMessage());
	    }
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
		try {
	    	response.setContentType("application/json");
	    	response.setHeader("Access-Control-Allow-Origin", "*"); // For development only, specify domains in production
	    	response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
	    	response.setHeader("Access-Control-Allow-Headers", "Content-Type");

	        JSONArray events = new JSONArray();

	        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	             Statement statement = connection.createStatement();
	             ResultSet rs = statement.executeQuery("SELECT accent, nume, prenume, start_c, end_c FROM concedii join useri on concedii.id_ang = useri.id join teme on useri.id = teme.id_usr")) {

	            while (rs.next()) {
	                JSONObject event = new JSONObject();
	                event.put("title", rs.getString("nume") + rs.getString("prenume"));
	                event.put("start", rs.getDate("start_c").toString());
	                event.put("end", rs.getDate("end_c").toString());
	                event.put("color", rs.getString("accent")); // Example color
	                event.put("textColor", "white");
	                events.put(event);
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	            throw new ServletException("Eroare BD=(", e);
	        }
	        System.out.println(events);
	        PrintWriter out = response.getWriter();
	        out.print(events.toString());
	    }
	    catch (Exception e) {
	        e.printStackTrace(); // Log server-side exceptions
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	        response.getWriter().write("Internal Server Error: " + e.getMessage());
	    }
	}

}
