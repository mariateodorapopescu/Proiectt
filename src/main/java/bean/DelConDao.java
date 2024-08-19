package bean;
// importare biblioteci
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/** 
 * Clasa care se ocupa cu stergerea unui concediu, facand legatura directa cu baza de date
 */
public class DelConDao {
/**
 * Sterge un concediu
 * @param concediu
 * @return numarul de linii modificate
 * @throws ClassNotFoundException
 * @throws SQLException
 */
    public int stergere(Concediu concediu) throws ClassNotFoundException, SQLException {
        // declarare si initializare variabile
        String sql = "delete from concedii WHERE id = ?;";
        int rezultat = 0;
        // initializare driver pentru baza de date
        Class.forName("com.mysql.cj.jdbc.Driver");
        // creare conexiune
        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        		// pregatire interogare
             PreparedStatement interogare = conexiune.prepareStatement(sql)) {
        	// setaree argumente wildcard in interogare ce depind de obiectul concediu primit, mai exact id-ul sau
            interogare.setInt(1, concediu.getId());
            // executare interogare
            rezultat = interogare.executeUpdate();
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
