package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class ModifConDao {

    public int check(ConcediuCon concediu) throws ClassNotFoundException, SQLException {
        // Correct SQL update statement
        String UPDATE_CONCEDII_SQL = "UPDATE concedii SET start_c = ?, end_c = ?, motiv = ?, locatie = ?, modified = (select current_date()) WHERE id = ?;";

        int result = 0;
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_CONCEDII_SQL)) {
            preparedStatement.setString(1, concediu.getStart());
            preparedStatement.setString(2, concediu.getEnd());
            preparedStatement.setString(3, concediu.getMotiv());
            preparedStatement.setString(4, concediu.getLocatie());
            preparedStatement.setInt(5, concediu.getId());

            result = preparedStatement.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
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
                    System.out.println("Cause: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}
