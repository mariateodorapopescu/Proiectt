package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DepDao {
	
	public int getNextId() throws SQLException, ClassNotFoundException {
	    int nextId = 0;
	    String SQL_SELECT_LAST_ID = "SELECT MAX(id_dep) FROM departament";

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

    public int addDep(String dep) throws ClassNotFoundException, SQLException {
        String INSERT_DEP_SQL = "INSERT INTO departament (id_dep, nume_dep) VALUES (?, ?);";

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(INSERT_DEP_SQL)) {
        	int nextId = getNextId();  // Get the next ID value
        	preparedStatement.setInt(1, nextId);
            preparedStatement.setString(2, dep);
            return preparedStatement.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
            throw e;
        }
    }

    private void printSQLException(SQLException ex) {
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
