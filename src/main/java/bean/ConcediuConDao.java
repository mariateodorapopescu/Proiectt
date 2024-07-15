package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.mindrot.jbcrypt.BCrypt;

public class ConcediuConDao {

	public int getNextId() throws SQLException, ClassNotFoundException {
		// de orice eventualitate
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

	public int check(ConcediuCon concediu) throws ClassNotFoundException, SQLException {
		// tre sa vad cum iau id_ul userului curent
	    String INSERT_USERS_SQL = "INSERT INTO concedii" +
	        "  (id_ang, start_c, end_c, motiv, locatie, status, concedii.tip, durata) VALUES " +
	        " (?, ?, ?, ?, ?, ?, ?, ?);";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");

	    int nextId = getNextId();  // Get the next ID value

	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USERS_SQL)) {
	        preparedStatement.setInt(1, concediu.getId_ang());
	        // ma complic... hai sa lasam data ca fiind string
	        preparedStatement.setString(2, concediu.getStart());
	        preparedStatement.setString(3, concediu.getEnd());
	        preparedStatement.setString(4, concediu.getMotiv());
	        preparedStatement.setString(5, concediu.getLocatie());
	        preparedStatement.setInt(6, concediu.getStatus());
	        preparedStatement.setInt(7, concediu.getTip());
	        preparedStatement.setInt(8, concediu.getDurata());
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
