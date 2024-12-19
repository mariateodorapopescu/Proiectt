 package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.mindrot.jbcrypt.BCrypt;
import bean.MyUser;

public class LoginDao {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    public MyUser validate(MyUser loginBean) throws SQLException, ClassNotFoundException {
        if (loginBean == null || loginBean.getUsername() == null || loginBean.getPassword() == null) {
            System.out.println("Login attempt failed: Invalid input data");
            return null;
        }

        System.out.println("Attempting login for user: " + loginBean.getUsername());
        MyUser user = null;
        Connection connection = null;

        try {
            // Load MySQL database driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish database connection
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Prepare and execute query
            String sql = "SELECT * FROM useri WHERE username = ?";
            try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
                preparedStatement.setString(1, loginBean.getUsername());
                
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("User found in database");
                        String hashedPassword = rs.getString("password");
                        
                        if (hashedPassword == null) {
                            System.out.println("Error: Stored password is null");
                            return null;
                        }

                        try {
                            if (BCrypt.checkpw(loginBean.getPassword(), hashedPassword)) {
                                System.out.println("Password match successful");
                                user = new MyUser();
                                user.setUsername(rs.getString("username"));
                                user.setTip(rs.getInt("tip"));
                                user.setPrenume(rs.getString("prenume"));
                                user.setId(rs.getInt("id"));
                                
                                // Update activ status
                                updateUserStatus(connection, loginBean.getUsername());
                            } else {
                                System.out.println("Password match failed for user: " + loginBean.getUsername());
                            }
                        } catch (IllegalArgumentException e) {
                            System.out.println("Error checking password: " + e.getMessage());
                            e.printStackTrace();
                            return null;
                        }
                    } else {
                        System.out.println("No user found with username: " + loginBean.getUsername());
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Database error occurred");
            printSQLException(e);
            throw e;
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL JDBC Driver not found");
            e.printStackTrace();
            throw e;
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                    System.out.println("Database connection closed");
                } catch (SQLException e) {
                    System.out.println("Error closing database connection");
                    e.printStackTrace();
                }
            }
        }
        
        return user;
    }

    private void updateUserStatus(Connection connection, String username) throws SQLException {
        if (connection == null || username == null) {
            System.out.println("Invalid parameters for updating user status");
            return;
        }

        String updateSQL = "UPDATE useri SET activ = 1 WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(updateSQL)) {
            stmt.setString(1, username);
            int rowsUpdated = stmt.executeUpdate();
            System.out.println("Updated activ status for " + username + ". Rows affected: " + rowsUpdated);
            
            if (rowsUpdated == 0) {
                System.out.println("Warning: No rows were updated for username: " + username);
            }
        } catch (SQLException e) {
            System.out.println("Error updating user status for " + username);
            throw e;
        }
    }

    private void printSQLException(SQLException ex) {
        if (ex == null) {
            return;
        }

        System.out.println("SQLException details:");
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                SQLException sqlEx = (SQLException) e;
                System.err.println("SQLState: " + sqlEx.getSQLState());
                System.err.println("Error Code: " + sqlEx.getErrorCode());
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