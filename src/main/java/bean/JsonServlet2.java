package bean;

import jakarta.servlet.ServletException;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import org.json.JSONArray;
/**
 * Servlet implementation class JsonServlet
 */
public class JsonServlet2 extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public JsonServlet2() {
        super();
        // TODO Auto-generated constructor stub
    }
    PrintWriter out;
    
 

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		
	        
	        String statusParam = request.getParameter("status");
            String depParam = request.getParameter("dep");

            int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
            int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
            Map<Integer, Integer> leaveCountMap = new HashMap<>();
            for (int i = 1; i <= 12; i++) {
                leaveCountMap.put(i, 0);
            }

            String baseQuery = "SELECT MONTH(month_dates) AS month, CEIL(COUNT(*) / 2) AS numar_concedii FROM (";

            String joinClause = " JOIN useri ON id_ang = useri.id JOIN departament ON useri.id_dep = departament.id_dep";
            String whereClause = " WHERE YEAR(start_c) = YEAR(CURRENT_DATE())";
            ArrayList<String> conditions = new ArrayList<>();

            if (status != 3) {
                conditions.add(" status = ?");
            }
            if (dep != -1) {
                conditions.add(" departament.id_dep = ?");
            }
            if (!conditions.isEmpty()) {
                whereClause += " AND " + String.join(" AND", conditions);
            }

            // Subqueries
            String subQuery1 = "SELECT start_c AS month_dates FROM concedii" + joinClause + whereClause;
            String subQuery2 = " UNION ALL SELECT end_c FROM concedii" + joinClause + whereClause;
            String subQuery3 = " UNION ALL SELECT DATE_ADD(start_c, INTERVAL 1 MONTH) AS month_dates FROM concedii" + joinClause + whereClause + " AND MONTH(start_c) <> MONTH(end_c)";

            // Final query
            String query = baseQuery + subQuery1 + subQuery2 + subQuery3 + ") AS combined_dates GROUP BY MONTH(month_dates)";

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }

            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement stmt = connection.prepareStatement(query)) {
                int paramIndex = 1;
                if (status != 3) {
                    stmt.setInt(paramIndex++, status);
                    stmt.setInt(paramIndex++, status);
                    stmt.setInt(paramIndex++, status);
                }
                if (dep != -1) {
                    stmt.setInt(paramIndex++, dep);
                    stmt.setInt(paramIndex++, dep);
                    stmt.setInt(paramIndex++, dep);
                }

                System.out.println(stmt);
                ResultSet rs1 = stmt.executeQuery();
                while (rs1.next()) {
                    int month = rs1.getInt("month");
                    int count = rs1.getInt("numar_concedii");
                    leaveCountMap.put(month, count);
                }

                ArrayList<Integer> months = new ArrayList<>();
                ArrayList<Integer> counts = new ArrayList<>();
                for (int i = 1; i <= 12; i++) {
                    months.add(i);
                    counts.add(leaveCountMap.get(i));
                }
                System.out.println(status + " " + dep);
                JSONObject json = new JSONObject();
                json.put("months", new JSONArray(months));
                json.put("counts", new JSONArray(counts));
                json.put("status", status);
                json.put("departament", dep);
                String statuss = "";
                String depp = "";
                if (status == -1) {
                	statuss = "respinse de sef";
                }
                if (status == -2) {
                	statuss = "respinse de director";
                }
                if (status == 1) {
                	statuss = "aprobate de sef";
                }
                if (status == 2) {
                	statuss = "aprobate de director";
                }
                if (status == 0) {
                	statuss = "in asteptare";
                }
                if (status == 3) {
                	statuss = "de orice fel";
                }
                if (dep == -1) {
                	depp = "toata institutia";
                } else {
                	  try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                          try (ResultSet rs2 = stm.executeQuery()) {
                              while (rs2.next()) {
                                  int id = rs2.getInt("id_dep");
                                  String nume = rs2.getString("nume_dep");
                                  if(dep == id)
                                  depp = "departamentul " + nume;
                              }
                          }
                      }
                }
                String msg = "Vizualizare concedii "+ statuss + " din " + depp;
                json.put("h3", msg);
                System.out.println(json);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setHeader("Access-Control-Allow-Origin", "*"); // for development only, specify domains in production
                response.setHeader("Access-Control-Allow-Methods", "POST");
                response.setHeader("Access-Control-Allow-Headers", "Content-Type");

                PrintWriter out = response.getWriter();
                out.print(json.toString());
                out.flush();
            } catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

	}

}