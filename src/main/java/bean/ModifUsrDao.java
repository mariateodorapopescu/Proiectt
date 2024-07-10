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

public class ModifUsrDao {

	public int registerEmployee(MyUser employee, String who) throws ClassNotFoundException, SQLException {
	    String INSERT_USERS_SQL = "UPDATE useri SET nume = ?, prenume = ?, data_nasterii = ?, adresa = ?, email = ?, telefon = ?, username = ?, id_dep = ?, tip = ? WHERE username = ?";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");
	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = con.prepareStatement(INSERT_USERS_SQL)) {
	        preparedStatement.setString(1, employee.getNume());
	        preparedStatement.setString(2, employee.getPrenume());
	        preparedStatement.setString(3, employee.getData_nasterii());
	        preparedStatement.setString(4, employee.getAdresa());
	        preparedStatement.setString(5, employee.getEmail());
	        preparedStatement.setString(6, employee.getTelefon());
	        preparedStatement.setString(7, employee.getUsername());
	        preparedStatement.setInt(8, employee.getDepartament());
	        preparedStatement.setInt(9, employee.getTip());
	        preparedStatement.setString(10, who);
	        System.out.println(who + " " + employee.getUsername());
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
