package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import bean.Adeverinta;

/**
 * Clasa pentru operațiile cu baza de date legate de adăugarea adeverințelor
 */
public class AdaugaAdeverintaDAO {
    private static final String URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String USER = "root";
    private static final String PASSWORD = "student";
    
    /**
     * Constructor
     */
    public AdaugaAdeverintaDAO() {
        // Încercăm să încărcăm driver-ul JDBC
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Nu s-a putut încărca driver-ul JDBC", e);
        }
    }
    
    /**
     * Adaugă o adeverință în baza de date
     * 
     * @param adeverinta Obiectul Adeverinta de adăugat
     * @return ID-ul adeverinței adăugate sau -1 în caz de eroare
     * @throws SQLException dacă apare o eroare de bază de date
     */
    public int incarca(Adeverinta adeverinta) throws SQLException {
        Connection conexiune = null;
        PreparedStatement stmt = null;
        
        try {
            conexiune = DriverManager.getConnection(URL, USER, PASSWORD);
            
            // Dezactivăm autocommit pentru a face operațiunile atomice
            conexiune.setAutoCommit(false);
            
            // Obținem următorul ID disponibil
            int nextId = getNextId(conexiune);
            
            // SQL pentru inserare
            String sql = "INSERT INTO adeverinte (id, id_ang, tip, pentru_servi, status, creare) VALUES (?, ?, ?, ?, ?, CURDATE())";
            
            stmt = conexiune.prepareStatement(sql);
            stmt.setInt(1, nextId); // Folosim ID-ul generat
            stmt.setInt(2, adeverinta.getIdAngajat());
            stmt.setInt(3, adeverinta.getTip());
            stmt.setString(4, adeverinta.getMentiuni());
            stmt.setInt(5, adeverinta.getStatus());
            
            // Executăm query-ul
            int result = stmt.executeUpdate();
            
            if (result > 0) {
                // Confirmăm tranzacția
                conexiune.commit();
                return nextId;
            } else {
                // Facem rollback în caz de eșec
                conexiune.rollback();
                return -1;
            }
        } catch (SQLException e) {
            // În caz de excepție, facem rollback
            if (conexiune != null) {
                try {
                    conexiune.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            // Închidem resursele
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conexiune != null) {
                try {
                    conexiune.setAutoCommit(true); // Resetăm autocommit
                    conexiune.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Obține următorul ID disponibil pentru tabela adeverinte
     * 
     * @param conexiune Conexiunea la baza de date
     * @return Următorul ID disponibil
     * @throws SQLException dacă apare o eroare de bază de date
     */
    private int getNextId(Connection conexiune) throws SQLException {
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            stmt = conexiune.createStatement();
            // Folosim COALESCE pentru a gestiona cazul când tabela e goală
            rs = stmt.executeQuery("SELECT COALESCE(MAX(id), 0) AS max_id FROM adeverinte");
            
            if (rs.next()) {
                return rs.getInt("max_id") + 1;
            }
            
            return 1; // Dacă nu există înregistrări, începem de la 1
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Verifică dacă adeverința există
     * 
     * @param id ID-ul adeverinței de verificat
     * @return true dacă adeverința există, false în caz contrar
     */
    public boolean existaAdeverinta(int id) {
        Connection conexiune = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conexiune = DriverManager.getConnection(URL, USER, PASSWORD);
            
            String sql = "SELECT 1 FROM adeverinte WHERE id = ?";
            stmt = conexiune.prepareStatement(sql);
            stmt.setInt(1, id);
            
            rs = stmt.executeQuery();
            return rs.next(); // Întoarce true dacă există cel puțin o înregistrare
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            // Închidem resursele
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conexiune != null) {
                try {
                    conexiune.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Obține status-ul unei adeverințe
     * 
     * @param id ID-ul adeverinței
     * @return Status-ul adeverinței sau -999 în caz de eroare
     */
    public int getStatusAdeverinta(int id) {
        Connection conexiune = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conexiune = DriverManager.getConnection(URL, USER, PASSWORD);
            
            String sql = "SELECT status FROM adeverinte WHERE id = ?";
            stmt = conexiune.prepareStatement(sql);
            stmt.setInt(1, id);
            
            rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("status");
            }
            
            return -999; // Adeverința nu există
            
        } catch (SQLException e) {
            e.printStackTrace();
            return -999;
        } finally {
            // Închidem resursele
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conexiune != null) {
                try {
                    conexiune.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}