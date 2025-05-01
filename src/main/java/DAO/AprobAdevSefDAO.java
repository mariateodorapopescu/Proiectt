package DAO;

import java.sql.*;

public class AprobAdevSefDAO {
    
    public void aprobare(int idAdeverinta, String mentiuni) throws ClassNotFoundException {
        String UPDATE_STATUS_SQL = "UPDATE adeverinte SET status = 1, modif = CURDATE(), motiv = ? WHERE id = ?";
        
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_STATUS_SQL)) {
            preparedStatement.setString(1, mentiuni);
            preparedStatement.setInt(2, idAdeverinta);

            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
        }
    }
    
    /**
	 * Afiseaza frumos / Pretty print o eroare dintr-o baza de date
	 * @param ex
	 */
	private static void printSQLException(SQLException ex) {
        for (Throwable e: ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                System.err.println("Stare: " + ((SQLException) e).getSQLState());
                System.err.println("Cod eroare: " + ((SQLException) e).getErrorCode());
                System.err.println("Explicatie: " + e.getMessage());
                Throwable t = ex.getCause();
                while (t != null) {
                    System.out.println("Cauza: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}