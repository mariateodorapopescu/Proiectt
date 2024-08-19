package bean;
// importuri de librarii
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 * acest Dao se ocupa de modificarea unui concediu
 */
public class ModifConDao {
/**
 * Functie ce efectiv face incarcarea/modificarea in baza de date a uui concediu
 * @param concediu
 * @return rezultatul update-ului
 * @throws ClassNotFoundException
 * @throws SQLException
 */
    public int check(Concediu concediu) throws ClassNotFoundException, SQLException {
        // declarare si initializare variabile
        String sql = "UPDATE concedii SET start_c = ?, end_c = ?, motiv = ?, locatie = ?, modified = (select current_date()) WHERE id = ?;";
        int rezultat = 0;
        
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stm = conexiune.prepareStatement(sql)) {
            stm.setString(1, concediu.getInceput());
            stm.setString(2, concediu.getSfarsit());
            stm.setString(3, concediu.getMotiv());
            stm.setString(4, concediu.getLocatie());
            stm.setInt(5, concediu.getId());

            rezultat = stm.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
        }
        return rezultat;
    }
    
    /**
	 * Afiseaza frumos / Pretty print o eroare dintr-o baza de date
	 * @param ex
	 */
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
