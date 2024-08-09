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

public class ResDirDao {

	public int modif(int id) throws ClassNotFoundException, SQLException {
	    String INSERT_USERS_SQL = "UPDATE concedii SET status = -2, acc_res = (select current_date()) WHERE id = ?";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");
	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = con.prepareStatement(INSERT_USERS_SQL)) {
	        preparedStatement.setInt(1, id);
	        result = preparedStatement.executeUpdate();
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return result;
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
