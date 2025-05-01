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
 * Clasa DAO pentru operațiile de ștergere a adeverințelor
 */
public class StergereAdeverintaDAO {
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
    public StergereAdeverintaDAO() {
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
     * Șterge o adeverință din baza de date
     * 
     * @param idAdeverinta ID-ul adeverinței care trebuie ștearsă
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean deleteAdeverinta(int idAdeverinta) {
        boolean success = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Verifică dacă adeverința există
            if (!adeverintaExists(idAdeverinta)) {
                return false;
            }
            
            // Query pentru a șterge adeverința
            String sql = "DELETE FROM adeverinte WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            
            // Execută query-ul
            int rowsAffected = preparedStatement.executeUpdate();
            
            // Verifică dacă ștergerea a avut succes
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
     * Șterge toate adeverințele unui angajat
     * 
     * @param idAngajat ID-ul angajatului
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteByAngajat(int idAngajat) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele unui angajat
            String sql = "DELETE FROM adeverinte WHERE id_ang = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAngajat);
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Șterge toate adeverințele cu un anumit status
     * 
     * @param status Status-ul adeverințelor care trebuie șterse
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteByStatus(int status) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele cu un anumit status
            String sql = "DELETE FROM adeverinte WHERE status = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, status);
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Șterge adeverințele mai vechi decât o anumită dată
     * 
     * @param data Data limită (se vor șterge adeverințele create înainte de această dată)
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteOlderThan(java.sql.Date data) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele mai vechi decât o anumită dată
            String sql = "DELETE FROM adeverinte WHERE creare < ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setDate(1, data);
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Șterge adeverințele de un anumit tip
     * 
     * @param tip Tipul adeverințelor care trebuie șterse
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteByTip(int tip) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele de un anumit tip
            String sql = "DELETE FROM adeverinte WHERE tip = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, tip);
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Șterge adeverințele cu un anumit motiv
     * 
     * @param motiv Motivul adeverințelor care trebuie șterse (se face căutare parțială)
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteByMotiv(String motiv) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele cu un anumit motiv
            String sql = "DELETE FROM adeverinte WHERE motiv LIKE ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, "%" + motiv + "%");
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Șterge adeverințele pentru angajații dintr-un anumit departament
     * 
     * @param idDepartament ID-ul departamentului
     * @return numărul de adeverințe șterse
     */
    public int deleteAdeverinteByDepartament(int idDepartament) {
        int deletedRows = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a șterge adeverințele angajaților dintr-un anumit departament
            String sql = "DELETE a FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "WHERE u.id_dep = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idDepartament);
            
            // Execută query-ul
            deletedRows = preparedStatement.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return deletedRows;
    }
    
    /**
     * Obține adeverințele care pot fi șterse (respinse sau mai vechi de o anumită perioadă)
     * 
     * @return Lista de adeverințe care pot fi șterse
     */
    public List<Adeverinta> getDeleteCandidates() {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a obține adeverințele care pot fi șterse
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire, " +
                         "d.nume_dep as departament, s.nume_status " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN statusuri s ON a.status = s.status " +
                         "WHERE a.status < 0 OR a.creare < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) " +
                         "ORDER BY a.creare ASC";
            
            statement = connection.createStatement();
            resultSet = statement.executeQuery(sql);
            
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
     * Golește complet tabela de adeverințe (ATENȚIE: Operațiune periculoasă!)
     * 
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean truncateAdeverinte() {
        boolean success = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a goli tabela
            String sql = "TRUNCATE TABLE adeverinte";
            
            statement = connection.createStatement();
            statement.executeUpdate(sql);
            
            success = true;
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return success;
    }
    
    /**
     * Verifică dacă o adeverință există în baza de date
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @return true dacă adeverința există, false în caz contrar
     */
    private boolean adeverintaExists(int idAdeverinta) throws SQLException {
        String sql = "SELECT COUNT(*) FROM adeverinte WHERE id = ?";
        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, idAdeverinta);
        resultSet = preparedStatement.executeQuery();
        
        if (resultSet.next()) {
            return resultSet.getInt(1) > 0;
        }
        
        return false;
    }
    
    /**
     * Obține numărul total de adeverințe
     * 
     * @return Numărul total de adeverințe
     */
    public int getTotalAdeverinte() {
        int total = 0;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a număra adeverințele
            String sql = "SELECT COUNT(*) FROM adeverinte";
            
            statement = connection.createStatement();
            resultSet = statement.executeQuery(sql);
            
            if (resultSet.next()) {
                total = resultSet.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return total;
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