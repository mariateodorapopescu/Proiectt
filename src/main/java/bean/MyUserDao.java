package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;
import bean.MyUser;

public class MyUserDao {

	public int getNextId() throws SQLException, ClassNotFoundException {
	    int nextId = 0;
	    String SQL_SELECT_LAST_ID = "SELECT MAX(id) FROM useri";

	    Class.forName("com.mysql.cj.jdbc.Driver");
	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(SQL_SELECT_LAST_ID)) {
	        
	        ResultSet rs = preparedStatement.executeQuery();
	        if (rs.next()) {
	            nextId = rs.getInt(1) + 1;
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return nextId;
	}

	public int registerEmployee(MyUser employee) throws ClassNotFoundException, SQLException {
	    String INSERT_USERS_SQL = "INSERT INTO useri" +
	        "  (nume, prenume, data_nasterii, adresa, email, telefon, username, password, id_dep, tip) VALUES " +
	        " (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");

	    int nextId = getNextId();  // Get the next ID value

	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USERS_SQL)) {
	    	String hashedPassword = BCrypt.hashpw(employee.getPassword(), BCrypt.gensalt());
//	        preparedStatement.setInt(1, nextId);
	        preparedStatement.setString(1, employee.getNume());
	        preparedStatement.setString(2, employee.getPrenume());
	        preparedStatement.setString(3, employee.getData_nasterii());
	        preparedStatement.setString(4, employee.getAdresa());
	        preparedStatement.setString(5, employee.getEmail());
	        preparedStatement.setString(6, employee.getTelefon());
	        preparedStatement.setString(7, employee.getUsername());
	        preparedStatement.setString(8, hashedPassword);
	        preparedStatement.setInt(9, employee.getDepartament());
	        preparedStatement.setInt(10, employee.getTip());
	        System.err.println(employee.getNume() + " " + employee.getPrenume() + " " + employee.getData_nasterii() + " " + employee.getAdresa() + " " + employee.getEmail() + " " + employee.getTelefon() +" " + employee.getUsername() + " " + employee.getPassword() + " " + employee.getDepartament() + " " + employee.getTip());
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
