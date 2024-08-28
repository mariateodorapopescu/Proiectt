package Servlet;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class SessionTimeoutListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // Sesiune creată
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // Sesiune distrusă
        if (se.getSession().isNew() == false) { // Verificați dacă sesiunea nu este nouă
            updateAllUsersInactive();
        }
    }

    private void updateAllUsersInactive() {
        Connection conn = null;
        Statement stmt = null;
        try {
            // Încercați să vă conectați la baza de date
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            stmt = conn.createStatement();

            // Actualizați toți utilizatorii ca inactivi
            stmt.executeUpdate("UPDATE useri SET activ = 0");

            System.out.println("All users have been set to inactive.");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
