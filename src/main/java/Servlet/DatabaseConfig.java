package Servlet;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DatabaseConfig - Configurația centralizată pentru conexiunea la baza de date
 * Modificați parametrii de mai jos conform setup-ului vostru
 */
public class DatabaseConfig {
    
    // MODIFICAȚI ACESTE VALORI CONFORM SETUP-ULUI VOSTRU
    private static final String DB_HOST = "localhost";
    private static final String DB_PORT = "3306";
    private static final String DB_NAME = "test";  // Numele bazei voastre de date
    private static final String DB_USER = "root"; // Username-ul vostru MySQL
    private static final String DB_PASSWORD = "student"; // Parola voastră MySQL
    
    // URL complet de conexiune
    private static final String JDBC_URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME + 
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8";
    
    /**
     * Obține o conexiune nouă la baza de date
     * @return Connection obiect pentru baza de date
     * @throws SQLException dacă conexiunea eșuează
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Încarcă driver-ul MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            System.out.println("🔌 Conectare la baza de date: " + JDBC_URL);
            
            // Creează conexiunea
            Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
            
            System.out.println("✅ Conexiune la baza de date stabilită cu succes!");
            
            return conn;
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL JDBC Driver nu a fost găsit!");
            System.err.println("💡 Asigurați-vă că aveți mysql-connector-java în classpath");
            throw new SQLException("MySQL JDBC Driver not found", e);
        } catch (SQLException e) {
            System.err.println("❌ Eroare la conectarea la baza de date:");
            System.err.println("🔗 URL: " + JDBC_URL);
            System.err.println("👤 User: " + DB_USER);
            System.err.println("📝 Eroare: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Testează conexiunea la baza de date
     * @return true dacă conexiunea reușește, false altfel
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("🧪 Test conexiune: SUCCESS");
            return true;
        } catch (SQLException e) {
            System.err.println("🧪 Test conexiune: FAILED - " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Afișează informații despre configurație
     */
    public static void printConfig() {
        System.out.println("📊 CONFIGURAȚIA BAZEI DE DATE:");
        System.out.println("🏠 Host: " + DB_HOST);
        System.out.println("🚪 Port: " + DB_PORT);
        System.out.println("💾 Database: " + DB_NAME);
        System.out.println("👤 User: " + DB_USER);
        System.out.println("🔗 URL: " + JDBC_URL);
    }
    
    /**
     * Metoda main pentru testare
     */
    public static void main(String[] args) {
        System.out.println("🚀 Testare configurație bază de date...\n");
        
        printConfig();
        System.out.println();
        
        if (testConnection()) {
            System.out.println("✅ Configurația este corectă!");
        } else {
            System.out.println("❌ Configurația nu funcționează!");
            System.out.println("\n💡 VERIFICAȚI:");
            System.out.println("1. MySQL server rulează");
            System.out.println("2. Baza de date '" + DB_NAME + "' există");
            System.out.println("3. Username și parola sunt corecte");
            System.out.println("4. mysql-connector-java.jar este în classpath");
        }
    }
    
    // Getters pentru parametrii de configurație
    public static String getDbHost() { return DB_HOST; }
    public static String getDbPort() { return DB_PORT; }
    public static String getDbName() { return DB_NAME; }
    public static String getDbUser() { return DB_USER; }
    public static String getJdbcUrl() { return JDBC_URL; }
}