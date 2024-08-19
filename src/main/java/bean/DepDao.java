package bean;
// importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
/**
 * Clasa care se ocupa cu incarcarea unui departament in baza de date
 */
public class DepDao {
	/**
	 * Functie ce afla urmatorul id (tabela nu are functia auto-increment la id)
	 * @return urmatorul id
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */
	public int getNextId() throws SQLException, ClassNotFoundException {
		// declarare si initializare variabile
	    int id = 0;
	    String sql = "SELECT MAX(id_dep) FROM departament";
	    // incarcare driver
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    // creare conexiune
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    		// pregatire interogare
	         PreparedStatement interogare = conexiune.prepareStatement(sql)) {
	        // executare interogare
	        ResultSet rezultat = interogare.executeQuery();
	        if (rezultat.next()) {
	        	// daca s-a intors ceva, se selecteaza, adunandu-se 1 pentru ca e ultimul id din tabel
	            id = rezultat.getInt(1) + 1;
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return id;
	}
	/**
	 * Aici are loc adaugarea propriu zisa
	 * @param dep
	 * @return numar de modificari facute
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 */
    public int addDep(String dep) throws ClassNotFoundException, SQLException {
    	// declarare si initializare variabile
        String sql = "INSERT INTO departament (id_dep, nume_dep) VALUES (?, ?);";
        // realizare conexiune
        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        		// pregatire interogare
             PreparedStatement interogare = conexiune.prepareStatement(sql)) {
        	// adaugare variabile
        	int nextId = getNextId();  
        	interogare.setInt(1, nextId);
            interogare.setString(2, dep);
            // executare interogare
            return interogare.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
            throw e;
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
