package bean;
// importare biblioteci
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
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONObject;

import org.json.JSONArray;
/**
 * implementare servlet care arunca un json 1
 */
public class JsonServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public JsonServlet() {
        super(); 
    }
    PrintWriter out;
   
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			String statusParam = request.getParameter("status");
            String depParam = request.getParameter("dep");
            String monthParam = request.getParameter("month");
            String type = request.getParameter("tip");
            
            int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
            int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
            int currentYear = Calendar.getInstance().get(Calendar.YEAR);
            int month2 = (monthParam != null) ? Integer.parseInt(monthParam) : Calendar.getInstance().get(Calendar.MONTH) + 1;
            int tip = (type != null) ? Integer.parseInt(type) : -1;
            System.out.println(status + " " + dep + " " + month2 + " " + currentYear + " " + tip);
            if (tip == 1) {
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
                     response.setHeader("Access-Control-Allow-Origin", "*");
                     response.setHeader("Access-Control-Allow-Methods", "POST");
                     response.setHeader("Access-Control-Allow-Headers", "Content-Type");

                     PrintWriter out = response.getWriter();
                     out.print(json.toString());
                     out.flush();
                 } catch (SQLException e) {
     				e.printStackTrace();
     			}
            }
            if (tip == 2) {
					
					Calendar calendar = Calendar.getInstance();
					calendar.set(Calendar.YEAR, currentYear);
					calendar.set(Calendar.MONTH, month2 - 1); // Adjust month index (-1 because Calendar.MONTH is zero-based)
					int daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
					
					Map<Integer, Integer> leaveCountMap = new HashMap<>();
					for (int i = 1; i <= daysInMonth; i++) {
					    leaveCountMap.put(i, 0);
					}
					
					 Map<String, List<String>> leaveDataByDate = new TreeMap<>();
		              String sql = "";
		              sql =  "SELECT nume, prenume, start_c, end_c FROM useri JOIN concedii ON useri.id = concedii.id_ang WHERE (MONTH(start_c) = ? OR MONTH(end_c) = ?) AND YEAR(start_c) = ?";
		              if (status != 3) {
	                	   sql += " and concedii.status = ?";
	                   }
		              if (dep != -1) {
		            	  sql += " and useri.id_dep = ?";
		              }
					 try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
							 PreparedStatement stmt = conn.prepareStatement(sql)) {
		                   stmt.setInt(1, month2);
		                   stmt.setInt(2, month2);
		                   stmt.setInt(3, calendar.get(Calendar.YEAR));
		                   int param = 4;
		                   if (status != 3) {
		                	   stmt.setInt(param++, status);
		                   }
		                   if (dep != -1) {
		                	   stmt.setInt(param++, dep);
		                   }
		                   ResultSet rs1 = stmt.executeQuery();
		                   String nume = "";
		                   String prenume = "";
		                   String fullnume = "";
		                   while (rs1.next()) {
		                       nume = rs1.getString("nume");
		                       prenume = rs1.getString("prenume");
		                       fullnume = nume + " " + prenume;

		                       LocalDate startDate = rs1.getDate("start_c").toLocalDate();
		                       LocalDate endDate = rs1.getDate("end_c").toLocalDate();

		                       LocalDate currentDate = startDate;

		                       while (!currentDate.isAfter(endDate)) {
		                           String dateKey = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		                           leaveDataByDate.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(fullnume);
		                           currentDate = currentDate.plusDays(1);
		                       }
		                   }
		               } catch (SQLException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					System.out.println(leaveDataByDate);
					 ArrayList<Integer> months = new ArrayList<>();
				        ArrayList<Integer> counts = new ArrayList<>();
				        
				        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd");
				        leaveDataByDate.forEach((dateKey, names) -> {
				            LocalDate date = LocalDate.parse(dateKey, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
				            months.add(Integer.parseInt(date.format(dayFormatter))); // Add day of month
				            counts.add(names.size()); // Add count of people
				        });
				        System.out.println(months);
				        System.out.println(counts);
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
                    	 try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    			 PreparedStatement stm = conn.prepareStatement("SELECT * FROM departament;")) {
                              try (ResultSet rs2 = stm.executeQuery()) {
                                  while (rs2.next()) {
                                      int id = rs2.getInt("id_dep");
                                      String nume = rs2.getString("nume_dep");
                                      if(dep == id)
                                      depp = "departamentul " + nume;
                                  }
                              }
                          } catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
                    }
                    String monthh = "";
                   
                    if (month2 == 1) {
                    	monthh = "Ianuarie";
                    }
                    if (month2 == 2) {
                    	monthh = "Februarie";
                    }
                    if (month2 == 3) {
                    	monthh = "Martie";
                    }
                    if (month2 == 4) {
                    	monthh = "Aprilie";
                    }
                    if (month2 == 5) {
                    	monthh = "Mai";
                    }
                    if (month2 == 6) {
                    	monthh = "Iunie";
                    }
                    if (month2 == 7) {
                    	monthh = "Iulie";
                    }
                    if (month2 == 8) {
                    	monthh = "August";
                    }
                    if (month2 == 9) {
                    	monthh = "Septembrie";
                    }
                    if (month2 == 10) {
                    	monthh = "Octombrie";
                    }
                    if (month2 == 11) {
                    	monthh = "Noiembrie";
                    }
                    if (month2 == 12) {
                    	monthh = "Decembrie";
                    }
                    String msg = "Vizualizare concedii "+ statuss + " din " + depp + " din luna " + monthh;
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
               
           }

	}

}