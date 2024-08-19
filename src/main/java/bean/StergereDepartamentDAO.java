package bean;
// importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 * Clasa ce se ocupa de stergerea unui departament si e legatura cu baza de date
 */
public class StergereDepartamentDAO {
	/**
	 * Functia care sterge efectiv
	 * @param username
	 * @param id
	 * @return numarul de linii modificate
	 * @throws SQLException
	 */
    public int stergere(String username, int id) throws SQLException {
        // declarare si initializare variabile
    	String sql1 = "DELETE FROM plecati WHERE id_dep = ?;"; // am avut un tabel intitulat plecati in care numaram pe zile cate persoane erau plecate
    	// din fiecare departament si acum terbuie sa sterg de aici mai intai datorita cheii straine
    	String sql2 = "DELETE FROM departament WHERE nume_dep = ?";
        int rezultat = 0;
	    Connection conexiune = null;
	    PreparedStatement interogare = null;

	    try {
	    	// creare conexiune propriu-zis
	        conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        conexiune.setAutoCommit(false); // dezactivare autocomit caci nu ma va lasa baza de date sa fac prea multe stergeri
	        interogare = conexiune.prepareStatement(sql1); // pregatire interogare
	        interogare.setInt(1, id);
	        // aceiasi pasi se fac si mai jos
	        interogare = conexiune.prepareStatement(sql2);
	        interogare.setString(1, username);
	        rezultat = interogare.executeUpdate();
	        // se face commit daca e ok ce se intampla
	        conexiune.commit(); 
	    } catch (SQLException e) {
	        if (conexiune != null) {
	            try {
	                conexiune.rollback(); // in caz de eroare, un fel de undo
	            } catch (SQLException ex) {
	                printSQLException(ex);
	            }
	        }
	        printSQLException(e);
	        throw e;
	    } finally {
	    	// indiferent daca e eroare sau nu, se inchide conexiunea
	        if (interogare != null) {
	            try {
	                interogare.close();
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
