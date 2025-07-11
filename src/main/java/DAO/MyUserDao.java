package DAO;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

import bean.MyUser;

public class MyUserDao {

	public int getNextId() throws SQLException, ClassNotFoundException {
	    int nextId = 0;
	    String SQL_SELECT_LAST_ID = "SELECT MAX(id) FROM useri";

	    Class.forName("com.mysql.cj.jdbc.Driver");
	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(SQL_SELECT_LAST_ID)) {
	        
	        ResultSet rs = preparedStatement.executeQuery();
	        if (rs.next()) {
	            nextId = rs.getInt(1) + 1;
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	    }
	    return nextId;
	}

	public int registerEmployee(MyUser employee) throws ClassNotFoundException, SQLException, IOException {
	    String INSERT_USERS_SQL = "INSERT INTO useri" +
	        "  (nume, prenume, data_nasterii, email, telefon, username, password, id_dep, tip, cnp, culoare) VALUES " +
	        " (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

	    int result = 0;

	    Class.forName("com.mysql.cj.jdbc.Driver");

	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USERS_SQL)) {
	    	String hashedPassword = BCrypt.hashpw(employee.getPassword(), BCrypt.gensalt());
//	        preparedStatement.setInt(1, nextId);
	        preparedStatement.setString(1, employee.getNume());
	        preparedStatement.setString(2, employee.getPrenume());
	        preparedStatement.setString(3, employee.getData_nasterii());
	      
	        preparedStatement.setString(4, employee.getEmail());
	        preparedStatement.setString(5, employee.getTelefon());
	        preparedStatement.setString(6, employee.getUsername());
	        preparedStatement.setString(7, hashedPassword);
	        preparedStatement.setInt(8, employee.getDepartament());
	        preparedStatement.setInt(9, employee.getTip());
	        preparedStatement.setString(10, employee.getCnp());
	        preparedStatement.setString(11, employee.getCuloare());
	        //System.err.println(employee.getNume() + " " + employee.getPrenume() + " " + employee.getData_nasterii() + " " + employee.getAdresa() + " " + employee.getEmail() + " " + employee.getTelefon() +" " + employee.getUsername() + " " + employee.getPassword() + " " + employee.getDepartament() + " " + employee.getTip());
	        /*
	        File imageFile = new File("C:\\Users\\Popi\\eclipse-workspace\\Proiect\\person.jpg");
	        try (FileInputStream fis = new FileInputStream(imageFile)) {
	            preparedStatement.setBinaryStream(13, fis, (int) imageFile.length());
	        } catch (FileNotFoundException e) {
	            System.out.println("Imaginea nu a fost găsită.");
	            e.printStackTrace();
	        }
	        */
	        result = preparedStatement.executeUpdate();

	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException();
	    }
	    // insertUserWithImage("C:\Users\Popi\eclipse-workspace\Proiect\person.jpg", id);
	    return result;
	}
	
	public void insertUserWithImage(String imagePath, int id) {
	    String INSERT_USERS_SQL = "INSERT INTO useri (profil) VALUES (?) where id = ?;";
	    File imageFile = new File(imagePath);
	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USERS_SQL);
	         FileInputStream fis = new FileInputStream(imageFile)) {

	        preparedStatement.setBinaryStream(1, fis, (int) imageFile.length());
	        preparedStatement.executeUpdate();
	    } catch (FileNotFoundException e) {
	        System.out.println("Imaginea nu a fost găsită.");
	        e.printStackTrace();
	    } catch (SQLException e) {
	        System.out.println("Eroare la baza de date.");
	        e.printStackTrace();
	    } catch (IOException e) {
	        System.out.println("Eroare la citirea fișierului.");
	        e.printStackTrace();
	    }
	}

	public List<String> getTipuri() throws SQLException {
        List<String> tipuri = new ArrayList<>();

	    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	         PreparedStatement preparedStatement = connection.prepareStatement("SELECT denumire FROM tipuri")) {
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                tipuri.add(rs.getString("denumire"));
            }
        }
        return tipuri;
    }

    public List<String> getDepartamente() throws SQLException {
        List<String> departamente = new ArrayList<>();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
   	         PreparedStatement preparedStatement = connection.prepareStatement("SELECT denumire FROM tipuri")) {
               ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                departamente.add(rs.getString("nume_dep"));
            }
        }
        return departamente;
    }
    private void printSQLException(SQLException ex) {
        for (Throwable e: ex) {
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
