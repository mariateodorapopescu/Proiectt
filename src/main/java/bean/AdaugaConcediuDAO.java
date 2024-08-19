package bean;
// importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 * Clasa care se ocupa de incarcarea unui concediu in baza de date
 */
public class AdaugaConcediuDAO {
	/**
	 * aceasta functie face incarcarea in baza de date
	 * @param concediu
	 * @return numar coloane modificate
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 */
	public int incarca(Concediu concediu) throws ClassNotFoundException, SQLException {
		// declarare si initializare variabile
	    String sql = "INSERT INTO concedii" +
	        "  (id_ang, start_c, end_c, motiv, locatie, status, concedii.tip, durata, added, modified, acc_res) VALUES " +
	        " (?, ?, ?, ?, ?, ?, ?, ?, (select current_date()), (select current_date()), (select current_date()));";
	    int rezultat = 0;
	    // initializare driver pentru comunicarea cu baza de date
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    // crearea conexiunii cu baza de date
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    		// pregatirea interogarii
	        PreparedStatement stmt = conexiune.prepareStatement(sql)) {
	    	// se adauga parametrii dati ca wildcards ce depind de obiectul primit, obiect facut de servlet, in functie de ce a primit de la formular
	        stmt.setInt(1, concediu.getId_ang());
	        stmt.setString(2, concediu.getInceput());
	        stmt.setString(3, concediu.getSfarsit());
	        stmt.setString(4, concediu.getMotiv());
	        stmt.setString(5, concediu.getLocatie());
	        stmt.setInt(6, concediu.getStatus());
	        stmt.setInt(7, concediu.getTip());
	        stmt.setInt(8, concediu.getDurata());
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
