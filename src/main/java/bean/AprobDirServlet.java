package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AprobDirServlet extends HttpServlet {
    private AprobDirDao dep;

    public void init() {
        dep = new AprobDirDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sesi = request.getSession(false); // This returns HttpSession directly
        if (sesi == null) {
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Sesiune nula!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }

        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser == null) {
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu e conectat niciun utilizator!');");
		    out.println("window.location.href = 'login.jsp';");
		    out.println("</script>");
		    out.close();
            return;
        }

        String username = currentUser.getUsername();
        int idcon = Integer.parseInt(request.getParameter("idcon"));

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            int uid = getEmployeeIdFromLeave(idcon, conn);
            int uidc = getUserIdByUsername(username, conn);

//            if (uid == uidc) {
//                response.sendRedirect("login.jsp"); // Cannot approve own leave
//                return;
//            }

            dep.modif(idcon); // Assuming this method handles the modification of the leave status
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Aprobare cu succes!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (SQLException e) {
            printSQLException(e);
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare la baza de date!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
        	e.printStackTrace();
        	 response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare la aprobare - nu s-a gasit clasa, debug only!');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
		}
    }

    private int getEmployeeIdFromLeave(int leaveId, Connection conn) throws SQLException {
        String query = "SELECT id_ang FROM concedii WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, leaveId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id_ang");
            }
        }
        return -1; // default or error case
    }

    private int getUserIdByUsername(String username, Connection conn) throws SQLException {
        String query = "SELECT id FROM useri WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return -1; // default or error case
    }

    private static void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
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
}
