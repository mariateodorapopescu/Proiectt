package bean;
//importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 * DAO pentru aprobare sef -> difera de DAO aprobari/respingeri prin SET status=-1!!
 */
public class ResSefDao {
	/**
	 * Functie ce face actiunea asupra concediului, actiune ce consta in modificarea unui camp, status
	 * @param id
	 * @return numar coloane modificate
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 */
	public int respingere(int id, String motiv) throws ClassNotFoundException, SQLException {
		// declarare si initializare variabile
	    //String sql = "UPDATE concedii SET status = 2, comm_dir = \"" + motiv + "\", acc_res = (select current_date()) WHERE id = ?";
	    String sql = "UPDATE concedii SET status = -1, mentiuni = \"" + motiv + "\", acc_res = (select current_date()) WHERE id = ? and id_ang != 0";
	// String sql = "UPDATE concedii SET status = 1, acc_res = (select current_date()) WHERE id = ? and id_ang != 0";
	    int result = 0;
	    // initializare driver pentru comunicarea cu baza de date
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    // conexiunea cu baza de date
	    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    		// pregatirea interogarii
	         PreparedStatement preparedStatement = con.prepareStatement(sql)) {
	        preparedStatement.setInt(1, id);
	        // executia interogarii
	        result = preparedStatement.executeUpdate();
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return result;
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
