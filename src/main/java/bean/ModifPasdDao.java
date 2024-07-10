package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;
import bean.MyUser;

public class ModifPasdDao {

	public int registerEmployee(String pass, String who) throws ClassNotFoundException, SQLException {
	    String INSERT_USERS_SQL = "UPDATE useri SET password = ? WHERE username = ?";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");
	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = con.prepareStatement(INSERT_USERS_SQL)) {
	    	String hash = BCrypt.hashpw(pass, BCrypt.gensalt());
	        preparedStatement.setString(1, hash);
	        preparedStatement.setString(2, who);
//	        System.err.println(pass);
	        System.err.println("dao " + who);
	        result = preparedStatement.executeUpdate();
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return result;
	}

	public List<String> getTipuri() throws SQLException {
        List<String> tipuri = new ArrayList<>();

	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement("SELECT denumire FROM tipuri")) {
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                tipuri.add(rs.getString("denumire"));
            }
        }
        return tipuri;
    }

    public List<String> getDepartamente() throws SQLException {
        List<String> departamente = new ArrayList<>();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
   	         PreparedStatement preparedStatement = connection.prepareStatement("SELECT denumire FROM tipuri")) {
               ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                departamente.add(rs.getString("nume_dep"));
            }
        }
        return departamente;
    }
    private void printSQLException(SQLException ex) {
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
}
