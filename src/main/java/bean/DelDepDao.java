package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DelDepDao {
	
    public int deleteUser(String username, int id) throws SQLException {
        
    	String DELETE_APPEARANCE_SQL = "DELETE FROM plecati WHERE id_dep = ?;";
    	String DELETE_USER_SQL = "DELETE FROM departament WHERE nume_dep = ?";
   
        int result = 0;
	    Connection con = null;
	    PreparedStatement preparedStatement = null;

	    try {
	        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        con.setAutoCommit(false); // Start transaction
	        
	        preparedStatement = con.prepareStatement(DELETE_APPEARANCE_SQL);
	        preparedStatement.setInt(1, id);
	        int appearanceResult = preparedStatement.executeUpdate();

	        // Now delete from user table
	        preparedStatement = con.prepareStatement(DELETE_USER_SQL);
	        preparedStatement.setString(1, username);
	        result = preparedStatement.executeUpdate();

	        con.commit(); // Commit transaction if both deletions were successful
	    } catch (SQLException e) {
	        if (con != null) {
	            try {
	                con.rollback(); // Roll back transaction on error
	            } catch (SQLException ex) {
	                printSQLException(ex);
	            }
	        }
	        printSQLException(e);
	        throw e;
	    } finally {
	        if (preparedStatement != null) {
	            try {
	                preparedStatement.close();
	            } catch (SQLException e) {
	                printSQLException(e);
	            }
	        }
	        if (con != null) {
	            try {
	                con.setAutoCommit(true);
	                con.close();
	            } catch (SQLException e) {
	                printSQLException(e);
	            }
	        }
	    }
	    return result;
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
                    System.out.println("Cause is: " + t);
                    t = t.getCause();
                }
            }
        }
    } 
}
