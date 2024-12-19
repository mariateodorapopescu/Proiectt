package mix;

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

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class GetLocationsServlet
 */
public class GetLocationsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GetLocationsServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
	            throws ServletException, IOException {
	        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student")) {
	            String sql = "SELECT latitudine, longitudine FROM locatii";
	            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
	                ResultSet rs = stmt.executeQuery();
	                JSONArray locations = new JSONArray();
	                while (rs.next()) {
	                    JSONObject location = new JSONObject();
	                    location.put("lat", rs.getDouble("latitudine"));
	                    location.put("long", rs.getDouble("longitudine"));
	                    location.put("descriere", rs.getString("descriere"));
	                    locations.put(location);
	                }
	                response.setContentType("application/json");
	                response.getWriter().write(locations.toString());
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	    }


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
