package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.mindrot.jbcrypt.BCrypt;

public class LoginDao {

    public MyUser validate(MyUser loginBean) throws SQLException, ClassNotFoundException {
        MyUser user = null;
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("select * from useri where username = ?")) {
            preparedStatement.setString(1, loginBean.getUsername());

            try (ResultSet rs = preparedStatement.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    if (BCrypt.checkpw(loginBean.getPassword(), hashedPassword)) {
                        user = new MyUser(); // Assuming MyUser has more fields you might want to fill
                        user.setUsername(loginBean.getUsername());
                        // Add other details as needed from ResultSet
                        String INSERT_USERS_SQL = "UPDATE useri SET activ = 1 WHERE username = ?";
                	    Class.forName("com.mysql.cj.jdbc.Driver");
                	    try (
                	         PreparedStatement preparedStatement1 = connection.prepareStatement(INSERT_USERS_SQL)) {
                	        
                	        preparedStatement1.setString(1, loginBean.getUsername());
                	    } catch (SQLException e) {
                	        printSQLException(e);
                	    }
                    }
                }
            }
        }
        return user;
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
