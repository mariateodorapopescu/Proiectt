package scheduler;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ContractTerminationScheduler implements ServletContextListener {
    
    private ScheduledExecutorService scheduler;
    
    @Override
    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        // Rulează task-ul zilnic la ora 00:01
        scheduler.scheduleAtFixedRate(
            new TerminationCheck(), 
            calculateInitialDelay(), 
            24 * 60 * 60, // 24 ore
            TimeUnit.SECONDS
        );
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent event) {
        scheduler.shutdownNow();
    }
    
    private long calculateInitialDelay() {
        // Calculează timpul până la ora 00:01 a zilei următoare
        // ...
        return 10; // Pornește după 10 secunde pentru test
    }
    
    private class TerminationCheck implements Runnable {
        @Override
        public void run() {
            Connection conn = null;
            try {
                // Încărcare driver MySQL
                Class.forName("com.mysql.cj.jdbc.Driver");
                
                // Creare conexiune directă
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                
                // 1. Dezactivează utilizatorii a căror dată de încetare a contractului a trecut
                String updateSql = "UPDATE useri u " +
                                  "JOIN istoric_incetari i ON u.id = i.id_ang " +
                                  "SET u.activ = 0 " +
                                  "WHERE i.data_incetare <= CURDATE() AND u.activ = 1";
                PreparedStatement updatePstmt = conn.prepareStatement(updateSql);
                int updatedRows = updatePstmt.executeUpdate();
                updatePstmt.close();
                
                // Logare pentru monitorizare
                System.out.println("Verificare contracte încetate. Utilizatori dezactivați: " + updatedRows);
                
                // 2. Dacă doriți să ștergeți și utilizatorii din baza de date după o anumită perioadă
                String deleteSql = "DELETE FROM useri " +
                                 "WHERE id IN (SELECT id_ang FROM istoric_incetari " +
                                 "WHERE data_incetare < DATE_SUB(CURDATE(), INTERVAL 30 DAY))";
                PreparedStatement deletePstmt = conn.prepareStatement(deleteSql);
                int deletedRows = deletePstmt.executeUpdate();
                deletePstmt.close();
                
                System.out.println("Utilizatori șterși din baza de date: " + deletedRows);
                
            } catch (ClassNotFoundException e) {
                System.err.println("Driver MySQL negăsit: " + e.getMessage());
                e.printStackTrace();
            } catch (SQLException e) {
                System.err.println("Eroare SQL: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (conn != null) {
                    try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        }
    }
}