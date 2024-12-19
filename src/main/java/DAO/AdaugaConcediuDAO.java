package DAO;
import bean.Concediu;
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
		    String sql = "INSERT INTO concedii " +
		        "(id_ang, start_c, end_c, motiv, locatie, status, tip, durata, added, modified, acc_res) VALUES " +
		        "(?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), CURDATE(), CURDATE())";
		    
		    System.out.println("Încercare inserare concediu pentru angajatul: " + concediu.getId_ang());
		    
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    
		    try (Connection conexiune = DriverManager.getConnection(
		            "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		         PreparedStatement stmt = conexiune.prepareStatement(sql)) {
		        
		        stmt.setInt(1, concediu.getId_ang());
		        stmt.setString(2, concediu.getInceput());
		        stmt.setString(3, concediu.getSfarsit());
		        stmt.setString(4, concediu.getMotiv());
		        stmt.setString(5, concediu.getLocatie());
		        stmt.setInt(6, concediu.getStatus());
		        stmt.setInt(7, concediu.getTip());
		        stmt.setInt(8, concediu.getDurata());
		        
		        System.out.println("Executing SQL: " + stmt.toString());
		        int rezultat = stmt.executeUpdate();
		        System.out.println("Rezultat inserare: " + rezultat);
		        return rezultat;
		    } catch (SQLException e) {
		        System.out.println("Eroare la inserare concediu:");
		        printSQLException(e);
		        throw e; // Retransmitem excepția
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
