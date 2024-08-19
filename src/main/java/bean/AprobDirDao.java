package bean;
//importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 * DAO pentru aprobare director -> difera de DAO aprobari/respingeri prin SET status=2!!
 */
public class AprobDirDao {
/**
 * Functie ce face actiunea asupra concediului, actiune ce consta in modificarea unui camp, status
 * @param id
 * @return numar coloane modificate
 * @throws ClassNotFoundException
 * @throws SQLException
 */
	public int aprobare(int id) throws ClassNotFoundException, SQLException {
		// declarare si initializare variabile
	    String sql = "UPDATE concedii SET status = 2, acc_res = (select current_date()) WHERE id = ?";
	    int rezultat = 0;
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    // creare conexiune cu baza de date
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    		// pregatire interogare
	         PreparedStatement stmt = conexiune.prepareStatement(sql)) {
	        stmt.setInt(1, id);
	        // executie interogare
	        rezultat = stmt.executeUpdate();
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return rezultat;
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
