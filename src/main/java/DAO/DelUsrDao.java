package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
// import variabile
/**
 * Clasa care prorpiu zis are in ea metoda de face stergerea din baza de date
 */
public class DelUsrDao {
	/**
	 * 
	 * @param numeutilizator
	 * @param id
	 * @return
	 * @throws SQLException
	 */
	public int deleteUser(String numeutilizator, int id) throws SQLException {
		// declrarare si initializare variabile
	    String sql2 = "DELETE FROM appearance WHERE id_usr = ?;";
	    String sql3 = "DELETE FROM useri WHERE username = ?;";
	    int rezultat = 0;
	    Connection conexiune = null;
	    PreparedStatement stmt = null;

	    try {
	    	// creare conexiune
	        conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        conexiune.setAutoCommit(false); 
	        
	        // Mai intai sterge utilizarorul ddin lista de oameni care au concedi in acea perioada care se afla in acel departament
	        stmt = conexiune.prepareStatement(sql2);
	        stmt.setInt(1, id);
	        // apoi se sterge utilizatorul
	        // asta datorita cheii externe
	        stmt = conexiune.prepareStatement(sql3);
	        stmt.setString(1, numeutilizator);
	        rezultat = stmt.executeUpdate();
	        // se da commit daca cele 2 stergeri nu au produs eroare + return
	        conexiune.commit(); 
	    } catch (SQLException e) {
	        if (conexiune != null) {
	            try {
	                conexiune.rollback(); // daca a aparut o eroare dam un undo ca nu stim unde a avut loc sau cam asa ceva
	            } catch (SQLException ex) {
	                printSQLException(ex);
	            }
	        }
	        printSQLException(e);
	        throw e;
	    } finally {
	    	// indiferent daca se sterge sau nu cu bine, inchidem conexiunile
	        if (stmt != null) {
	            try {
	                stmt.close();
	            } catch (SQLException e) {
	                printSQLException(e);
	            }
	        }
	        if (conexiune != null) {
	            try {
	                conexiune.setAutoCommit(true);
	                conexiune.close();
	            } catch (SQLException e) {
	                printSQLException(e);
	            }
	        }
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
