package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.mindrot.jbcrypt.BCrypt;

import bean.MyUser;

public class LoginDao {

    public MyUser validate(MyUser loginBean) throws SQLException, ClassNotFoundException {
        MyUser user = null;
        // Load MySQL database driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Use try-with-resources for efficient handling of the JDBC resources.
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            
            preparedStatement.setString(1, loginBean.getUsername());

            try (ResultSet rs = preparedStatement.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    if (BCrypt.checkpw(loginBean.getPassword(), hashedPassword)) {
                        user = new MyUser(); // Assuming MyUser has more fields you might want to fill
                        user.setUsername(loginBean.getUsername());
                        // Potentially add other details as needed from ResultSet

                        // Update the 'activ' status in the database
                        String INSERT_USERS_SQL = "UPDATE useri SET activ = 1 WHERE username = ?";
                        try (PreparedStatement preparedStatement1 = connection.prepareStatement(INSERT_USERS_SQL)) {
                            preparedStatement1.setString(1, loginBean.getUsername());
                            preparedStatement1.executeUpdate(); // This line executes the update
                        }
                    }
                }
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return user;
    }

    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
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
