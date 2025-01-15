 package mix;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;

import org.json.JSONArray;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;


public class GetVacationDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public GetVacationDetailsServlet() {
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

        try {
            // Conectare la baza de date
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");

            // Interogare pentru a obține localitățile unice din tabelul locatii_useri
            // String query = "SELECT DISTINCT oras FROM locatii_concedii";
            String query = "SELECT DISTINCT oras, judet FROM locatii_useri ORDER BY oras";
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        // For JSON approach, parse the request body
        if (request.getContentType() != null && request.getContentType().contains("application/json")) {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            
            // Parse JSON
            JsonObject jsonObject = new Gson().fromJson(buffer.toString(), JsonObject.class);
            int period = jsonObject.get("period").getAsInt();
            Integer idDep = jsonObject.has("id_dep") ? jsonObject.get("id_dep").getAsInt() : null;
            
            // Process and return data
            processRequest(period, idDep, out);
        } 
        // For form approach, get parameters directly
        else {
            int period = Integer.parseInt(request.getParameter("period"));
            Integer idDep = request.getParameter("id_dep") != null ? 
                          Integer.parseInt(request.getParameter("id_dep")) : null;
            
            // Process and return data
            processRequest(period, idDep, out);
        }
    }
    
    private void processRequest(int period, Integer idDep, PrintWriter out) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        JsonArray jsonArray = new JsonArray();
        
        try {
            // Establish database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Prepare SQL query based on whether idDep is provided
            String sql = "SELECT c.*, u.*, concat(l.oras,', ',l.judet) as localitate, l.latitudine, l.longitudine " +
                        "FROM concedii c " +
                        "JOIN locatii_concedii l ON c.id = l.id_concediu " +
                        "JOIN useri u ON c.id_ang = u.id " +
                        "WHERE MONTH(c.start_c) = ?";
            
            if (idDep != null) {
                sql += " AND u.id_dep = ?";
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, period);
            
            if (idDep != null) {
                pstmt.setInt(2, idDep);
            }
            
            rs = pstmt.executeQuery();
            
            // Process results and build JSON array
            while (rs.next()) {
                JsonObject vacation = new JsonObject();
                vacation.addProperty("id", rs.getInt("id"));
                vacation.addProperty("startDate", rs.getString("start_c"));
                vacation.addProperty("endDate", rs.getString("end_c"));
                vacation.addProperty("address", rs.getString("localitate"));
                vacation.addProperty("latitude", rs.getDouble("latitudine"));
                vacation.addProperty("longitude", rs.getDouble("longitudine"));
                vacation.addProperty("userId", rs.getInt("id"));
                vacation.addProperty("departmentId", rs.getInt("id_dep"));
                
                jsonArray.add(vacation);
            }
            
            // Write JSON response
            out.println(jsonArray.toString());
            
        } catch (Exception e) {
            // Log the error
            e.printStackTrace();
            // Return empty array on error
            out.println("[]");
            
        } finally {
            // Close all resources
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Helper method to check if vacation dates overlap with the selected period
    private boolean isVacationInPeriod(Date startDate, Date endDate, int selectedPeriod) {
        Calendar cal = Calendar.getInstance();
        
        // Check start date month
        cal.setTime(startDate);
        int startMonth = cal.get(Calendar.MONTH) + 1; // Calendar months are 0-based
        
        // Check end date month
        cal.setTime(endDate);
        int endMonth = cal.get(Calendar.MONTH) + 1;
        
        // Vacation is in period if either start or end date is in the selected month
        return selectedPeriod == startMonth || selectedPeriod == endMonth ||
               (startMonth < selectedPeriod && endMonth > selectedPeriod);
    } 

} 