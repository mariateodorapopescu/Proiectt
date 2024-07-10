package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AddConServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
    public AddConServlet() {
        super();
    }
    
    private ConcediuConDao concediu;

    public void init() {
        concediu = new ConcediuConDao();
    }
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected Data toData(String data) {
		 String[] parts = data.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int uid = Integer.valueOf(request.getParameter("userId"));
		String start = request.getParameter("start");
		String end = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");

        ConcediuCon con = new ConcediuCon();
        con.setId_ang(uid);
        con.setStart(start);
        con.setEnd(end);
        con.setMotiv(motiv);
        con.setLocatie(locatie);
        
        try {
			if (!maimulteconcedii(request)) {
				System.out.println("deja are prea multe concedii");
				response.sendRedirect("err.jsp?dn=true");
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        try {
			if (!maimultezile(request)) {
				System.out.println("deja are prea multe zile in total");
				response.sendRedirect("err.jsp?dn=true");
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        try {
			if (!odatavara(request) && (toData(con.getStart()).getLuna() >= 6 && toData(con.getStart()).getLuna() <= 8)) {
				System.out.println("deja are vara");
				response.sendRedirect("err.jsp?dn=true");
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        if (!maimultezileodata(con)) {
        	System.out.println("deja are prea multe zile deodata");
			response.sendRedirect("err.jsp?dn=true");
			return;
		}
        
        System.out.println("am ajuns dupa maimultezileodata");
        
        try {
			if (!preamulti(con, request)) {
				response.sendRedirect("err.jsp?dn=true");
				return;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        System.out.println("am ajuns dupa preamulti");
	    
        
        String QUERY2 = "select * from useri where id = ?;";
	    int userType = -1;
	    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		         PreparedStatement stm = conn.prepareStatement(QUERY2)) {
		        stm.setInt(1, uid);
		        try (ResultSet res = stm.executeQuery()) {
		            if (res.next()) {
		                userType = res.getInt("tip");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred", e);
		    }
	    
	    if (userType == 0) {
	    	 try {
	 			if (!preamultid(con, request)) {
	 				response.sendRedirect("err.jsp?dn=true");
	 				return;
	 			}
	 		} catch (ClassNotFoundException e) {
	 			// TODO Auto-generated catch block
	 			e.printStackTrace();
	 		} catch (IOException e) {
	 			// TODO Auto-generated catch block
	 			e.printStackTrace();
	 		}
	    }
	    
	    System.out.println(userType);
	    
	    if (userType == 0 || userType == 3) {
	    	con.setStatus(1);
	    } else {
	    	con.setStatus(0);
	    }
       
	    System.out.println("trimitere");
	    
        try {
            concediu.check(con);
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("why are you crying?!");
            response.sendRedirect("err.jsp");
        }
	}
	
		private static void printSQLException(SQLException ex) {
	        for (Throwable e: ex) {
	            if (e instanceof SQLException) {
	                e.printStackTrace(System.err);
	                System.err.println("SQLState: " + ((SQLException) e).getSQLState());
	                System.err.println("Error Code: " + ((SQLException) e).getErrorCode());
	                System.err.println("Message: " + e.getMessage());
	                Throwable t = ex.getCause();
	                while (t != null) {
	                    System.out.println("Cause: " + t);
	                    t = t.getCause();
	                }
	            }
	        }
	    }
		
		public static boolean maimulteconcedii(HttpServletRequest request) throws ClassNotFoundException, IOException {
		    int nr = 0;
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    String QUERY = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE useri.id = ?;";
		    int uid = Integer.valueOf(request.getParameter("userId"));

		    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
		        preparedStatement.setInt(1, uid);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            if (rs.next()) {
		                nr = rs.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred", e);
		    }

		    return nr < 3;
		}

		public static boolean maimultezile(HttpServletRequest request) throws ClassNotFoundException, IOException {
			int nr = 0;
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    String QUERY = "select sum(datediff(end_c, start_c)) as total from concedii join useri on concedii.id_ang = useri.id where id_ang = ?;";
		    int uid = Integer.valueOf(request.getParameter("userId"));
		    String QUERY2 = "select * from useri where id = ?;";
		    int userType = 0;
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			         PreparedStatement stm = conn.prepareStatement(QUERY2)) {
			        stm.setInt(1, uid);
			        try (ResultSet res = stm.executeQuery()) {
			            if (res.next()) {
			                userType = res.getInt("tip");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Database error occurred", e);
			    }
		    
		    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
		        preparedStatement.setInt(1, uid);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            if (rs.next()) {
		                nr = rs.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred", e);
		    }
		    if (userType == 2) {
		    	return nr < 30;
		    }
		    return nr < 40;
	}
		
		public static boolean odatavara(HttpServletRequest request) throws ClassNotFoundException, IOException{
			 int nr = 0;
			    Class.forName("com.mysql.cj.jdbc.Driver");
			    String QUERY = "SELECT count(*) as total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE id_ang = ? AND MONTH(start_c) >=6 AND MONTH(start_c) <= 8;";
			    int uid = Integer.valueOf(request.getParameter("userId"));

			    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			         PreparedStatement preparedStatement = con.prepareStatement(QUERY)) {
			        preparedStatement.setInt(1, uid);
			        try (ResultSet rs = preparedStatement.executeQuery()) {
			            if (rs.next()) {
			                nr = rs.getInt("total");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Database error occurred", e);
			    }

			    return nr < 1;
		}
		
		public static int contor(Data startt, Data endd) {
			int contor = 0;
	        if (startt.getLuna() == endd.getLuna()) {
	            contor = endd.getZi() - startt.getZi() + 1;
	        } else {
	            if (startt.getLuna() == 1 || startt.getLuna() == 3 || startt.getLuna() == 5 || startt.getLuna() == 7
	                    || startt.getLuna() == 8 || startt.getLuna() == 10 || startt.getLuna() == 12) {
	                contor = 31 - startt.getZi() + endd.getZi() + 1;
	            } else if (startt.getLuna() == 4 || startt.getLuna() == 6 || startt.getLuna() == 9 || startt.getLuna() == 11) {
	                contor = 30 - startt.getZi() + endd.getZi() + 1;
	            } else {
	                if (startt.getAn() % 4 == 0) {
	                    contor = 29 - startt.getZi() + endd.getZi() + 1;
	                } else {
	                    contor = 28 - startt.getZi() + endd.getZi() + 1;
	                }
	            }
	        }
	        return contor;
	    }
		
		public static boolean maimultezileodata(ConcediuCon concediu) {
			int nr = 0;
			 Data start_c = stringToDate(concediu.getStart());
		     Data end_c = stringToDate(concediu.getEnd());
		     nr = contor(start_c, end_c);
		     return nr < 21;
		}
		
		public static Data stringToDate(String dateString) {
	        String[] parts = dateString.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
	    }
		
		public static boolean preamulti(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException {
		    int nr = -1;
		    int total = -1;
		    int depid = -1;

		    Class.forName("com.mysql.cj.jdbc.Driver");

		    // Get the department ID first
		    String queryUserDep = "SELECT id_dep FROM useri WHERE id = ?";
		    int uid = Integer.parseInt(request.getParameter("userId"));

		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtUserDep = conn.prepareStatement(queryUserDep)) {
		        stmtUserDep.setInt(1, uid);
		        try (ResultSet rsUserDep = stmtUserDep.executeQuery()) {
		            if (rsUserDep.next()) {
		                depid = rsUserDep.getInt("id_dep");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred while fetching department ID", e);
		    }
		    System.out.println(depid);
		    // Check total users in department
		    String queryTotalUsers = "SELECT COUNT(*) AS total FROM useri WHERE id_dep = ?";
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtTotalUsers = conn.prepareStatement(queryTotalUsers)) {
		        stmtTotalUsers.setInt(1, depid);
		        try (ResultSet rsTotalUsers = stmtTotalUsers.executeQuery()) {
		            if (rsTotalUsers.next()) {
		                total = rsTotalUsers.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred while counting users in department", e);
		    }
		    System.out.println(total);
		    // Check total leaves in department within specific dates
		    String queryTotalLeaves = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON useri.id = concedii.id_ang " +
		        "WHERE useri.id_dep = ? AND start_c >= ? AND end_c <= ?";
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmtTotalLeaves = conn.prepareStatement(queryTotalLeaves)) {
		        Data start_c = stringToDate(concediu.getStart());
		        Data end_c = stringToDate(concediu.getEnd());

		        stmtTotalLeaves.setInt(1, depid);
		        stmtTotalLeaves.setDate(2, java.sql.Date.valueOf(start_c.getAn() + "-" + start_c.getLuna() + "-" + start_c.getZi()));
		        stmtTotalLeaves.setDate(3, java.sql.Date.valueOf(end_c.getAn() + "-" + end_c.getLuna() + "-" + end_c.getZi()));
		        try (ResultSet rsTotalLeaves = stmtTotalLeaves.executeQuery()) {
		            if (rsTotalLeaves.next()) {
		                nr = rsTotalLeaves.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Database error occurred while counting leaves", e);
		    }
		    System.out.println(nr);
		    return nr <= (total / 2);
		}
		
		public static boolean preamultid(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
				 int nr = 0;
				    Class.forName("com.mysql.cj.jdbc.Driver");
				    String QUERY = "select count(*) as total from concedii join useri on useri.id = concedii.id_ang where day(start_c) >= ? and month(start_c) = ? and day(start_c) <= ? and month(start_c) <= ? group by tip having tip = 0;";
				  
				    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
				         PreparedStatement stm = con.prepareStatement(QUERY)) {
				        Data start_c = stringToDate(concediu.getStart());
				        Data end_c = stringToDate(concediu.getEnd());
				        stm.setInt(1, start_c.getZi());
				        stm.setInt(2, start_c.getLuna());
				        stm.setInt(3, end_c.getZi());
				        stm.setInt(4, end_c.getLuna());
				        try (ResultSet rs = stm.executeQuery() ) {
				            if (rs.next()) {
				                nr = rs.getInt("total");
				            }
				        }
				    } catch (SQLException e) {
				        printSQLException(e);
				        throw new IOException("Database error occurred", e);
				    }

				    return nr < 2;
			}
		
	    public static boolean validate(ConcediuCon concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
	    	int uid = Integer.valueOf(request.getParameter("userId"));
		    String QUERY2 = "select * from useri where id = ?;";
		    int userType = -1;
		    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
			         PreparedStatement stm = conn.prepareStatement(QUERY2)) {
			        stm.setInt(1, uid);
			        try (ResultSet res = stm.executeQuery()) {
			            if (res.next()) {
			                userType = res.getInt("tip");
			            }
			        }
			    } catch (SQLException e) {
			        printSQLException(e);
			        throw new IOException("Database error occurred", e);
			    }
		    
	    	if (userType == 0) {
	    		return maimulteconcedii(request) && maimultezile(request) && odatavara(request) & maimultezileodata(concediu) && preamulti(concediu, request) && preamultid(concediu, request);
	    	} 
	    	return maimulteconcedii(request) && maimultezile(request) && odatavara(request) && maimultezileodata(concediu) && preamulti(concediu, request);
	    }

}
