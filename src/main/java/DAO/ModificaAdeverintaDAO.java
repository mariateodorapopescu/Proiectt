package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import bean.Adeverinta;

/**
 * Clasa DAO pentru operațiile de modificare a adeverințelor
 */
public class ModificaAdeverintaDAO {
    private Connection connection;
    private Statement statement;
    private PreparedStatement preparedStatement;
    private ResultSet resultSet;
    
    // Constante pentru configurarea conexiunii
    private static final String URL = "jdbc:mysql://localhost:3306/test";
    private static final String USER = "root";
    private static final String PASSWORD = "student";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    /**
     * Constructor care încarcă driver-ul JDBC
     */
    public ModificaAdeverintaDAO() {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Obține conexiunea la baza de date
     * 
     * @return Conexiunea la baza de date
     * @throws SQLException Dacă apare o eroare la conectare
     */
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    /**
     * Obține detaliile unei adeverințe specifice
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @return Obiectul Adeverinta sau null dacă nu a fost găsit
     */
    public Adeverinta getAdeverintaById(int idAdeverinta) {
        Adeverinta adeverinta = null;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a obține detaliile adeverinței
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire, " +
                         "d.nume_dep as departament, s.nume_status " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN statusuri s ON a.status = s.status " +
                         "WHERE a.id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            resultSet = preparedStatement.executeQuery();
            
            // Procesare rezultat
            if (resultSet.next()) {
                adeverinta = new Adeverinta();
                adeverinta.setId(resultSet.getInt("id"));
                adeverinta.setTip(resultSet.getInt("tip"));
                adeverinta.setMotiv(resultSet.getString("motiv"));
                adeverinta.setStatus(resultSet.getInt("status"));
                adeverinta.setCreare(resultSet.getDate("creare"));
                adeverinta.setModif(resultSet.getDate("modif"));
                
                adeverinta.setIdAngajat(resultSet.getInt("id_ang"));
                
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return adeverinta;
    }
    
    /**
     * Actualizează datele unei adeverințe
     * 
     * @param adeverinta Adeverința cu datele actualizate
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean updateAdeverinta(Adeverinta adeverinta) {
        boolean success = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a actualiza adeverința
            String sql = "UPDATE adeverinte SET tip = ?, motiv = ?, modif = CURDATE() WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, adeverinta.getTip());
            preparedStatement.setString(2, adeverinta.getMotiv());
            preparedStatement.setInt(3, adeverinta.getId());
            
            // Execută update-ul
            int rowsAffected = preparedStatement.executeUpdate();
            
            // Verifică dacă update-ul a avut succes
            if (rowsAffected > 0) {
                success = true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return success;
    }
    
    /**
     * Actualizează statusul unei adeverințe
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @param newStatus Noul status
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean updateAdeverintaStatus(int idAdeverinta, int newStatus) {
        boolean success = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a actualiza statusul adeverinței
            String sql = "UPDATE adeverinte SET status = ?, modif = CURDATE() WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, newStatus);
            preparedStatement.setInt(2, idAdeverinta);
            
            // Execută update-ul
            int rowsAffected = preparedStatement.executeUpdate();
            
            // Verifică dacă update-ul a avut succes
            if (rowsAffected > 0) {
                success = true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return success;
    }
    
    /**
     * Adaugă o nouă adeverință
     * 
     * @param adeverinta Noua adeverință
     * @return ID-ul adeverinței adăugate sau -1 dacă operația a eșuat
     */
    public int addAdeverinta(Adeverinta adeverinta) {
        int newId = -1;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a adăuga o nouă adeverință
            String sql = "INSERT INTO adeverinte (id_ang, tip, motiv, status, creare, modif) VALUES (?, ?, ?, 0, CURDATE(), CURDATE())";
            
            preparedStatement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            preparedStatement.setInt(1, adeverinta.getIdAngajat());
            preparedStatement.setInt(2, adeverinta.getTip());
            preparedStatement.setString(3, adeverinta.getMotiv());
            
            // Execută inserarea
            int rowsAffected = preparedStatement.executeUpdate();
            
            // Obține ID-ul generat automat
            if (rowsAffected > 0) {
                resultSet = preparedStatement.getGeneratedKeys();
                if (resultSet.next()) {
                    newId = resultSet.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return newId;
    }
    
    /**
     * Verifică dacă o adeverință poate fi modificată (doar statusul 0 - neaprobat)
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @return true dacă adeverința poate fi modificată, false în caz contrar
     */
    public boolean canModifyAdeverinta(int idAdeverinta) {
        boolean canModify = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a verifica statusul adeverinței
            String sql = "SELECT status FROM adeverinte WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            resultSet = preparedStatement.executeQuery();
            
            if (resultSet.next()) {
                int status = resultSet.getInt("status");
                // Poate fi modificată doar dacă statusul este 0 (neaprobată)
                canModify = (status == 0);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return canModify;
    }
    
    /**
     * Obține toate tipurile de adeverințe disponibile
     * 
     * @return Lista de tipuri de adeverințe (id, denumire)
     */
    public List<Object[]> getAllTipuriAdeverinte() {
        List<Object[]> tipuri = new ArrayList<>();
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a obține toate tipurile de adeverințe
            String sql = "SELECT id, denumire FROM tip_adev ORDER BY denumire";
            
            statement = connection.createStatement();
            resultSet = statement.executeQuery(sql);
            
            // Procesare rezultate
            while (resultSet.next()) {
                Object[] tip = new Object[2];
                tip[0] = resultSet.getInt("id");
                tip[1] = resultSet.getString("denumire");
                tipuri.add(tip);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return tipuri;
    }
    
    /**
     * Obține adeverințele create de un anumit angajat
     * 
     * @param idAngajat ID-ul angajatului
     * @return Lista de adeverințe ale angajatului
     */
    public List<Adeverinta> getAdeverinteByAngajat(int idAngajat) {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a obține adeverințele unui angajat
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire, " +
                         "s.nume_status " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "JOIN statusuri s ON a.status = s.status " +
                         "WHERE a.id_ang = ? ORDER BY a.creare DESC";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAngajat);
            resultSet = preparedStatement.executeQuery();
            
            // Procesare rezultate
            while (resultSet.next()) {
                Adeverinta adeverinta = new Adeverinta();
                adeverinta.setId(resultSet.getInt("id"));
                adeverinta.setTip(resultSet.getInt("tip"));
                adeverinta.setMotiv(resultSet.getString("motiv"));
                adeverinta.setStatus(resultSet.getInt("status"));
                adeverinta.setCreare(resultSet.getDate("creare"));
                adeverinta.setModif(resultSet.getDate("modif"));
               
                adeverinta.setIdAngajat(resultSet.getInt("id_ang"));
                
                
                adeverinte.add(adeverinta);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return adeverinte;
    }
    
    /**
     * Metoda pentru închiderea resurselor
     */
    private void close() {
        try {
            if (resultSet != null) {
                resultSet.close();
            }
            
            if (statement != null) {
                statement.close();
            }
            
            if (preparedStatement != null) {
                preparedStatement.close();
            }
            
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}