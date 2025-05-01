package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

import bean.Adeverinta;

/**
 * Clasa DAO pentru gestionarea aprobării adeverințelor de către șef
 */
public class ResAdevSefDAO {
    private DataSource dataSource;
    private Connection connection;
    private Statement statement;
    private PreparedStatement preparedStatement;
    private ResultSet resultSet;

    /**
     * Constructor care inițializează conexiunea la baza de date
     */
    public ResAdevSefDAO() {
        // Inițializează sursa de date
       super();
    }

    /**
     * Obține toate adeverințele care așteaptă aprobarea șefului
     * 
     * @return Lista de adeverințe care așteaptă aprobarea
     */
    public List<Adeverinta> getAdeverintePendingApproval() {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a obține adeverințele cu status 0 (neaprobate)
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "WHERE a.status = 0 ORDER BY a.creare DESC";
            
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
     * Obține toate adeverințele pentru un anumit departament care așteaptă aprobarea șefului
     * 
     * @param idDepartament ID-ul departamentului
     * @return Lista de adeverințe care așteaptă aprobarea
     */
    public List<Adeverinta> getAdeverintePendingApprovalByDepartment(int idDepartament) {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a obține adeverințele cu status 0 (neaprobate) dintr-un anumit departament
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "WHERE a.status = 0 AND u.id_dep = ? ORDER BY a.creare DESC";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idDepartament);
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
     * Aprobă o adeverință (actualizează statusul la 1 - Aprobat de șef)
     * 
     * @param idAdeverinta ID-ul adeverinței care trebuie aprobată
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean approveAdeverinta(int idAdeverinta) {
        boolean success = false;
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a actualiza statusul adeverinței
            String sql = "UPDATE adeverinte SET status = 1, modif = CURDATE() WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            
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
     * Respinge o adeverință (actualizează statusul la -1 - Respins de șef)
     * 
     * @param idAdeverinta ID-ul adeverinței care trebuie respinsă
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean rejectAdeverinta(int idAdeverinta) {
        boolean success = false;
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a actualiza statusul adeverinței
            String sql = "UPDATE adeverinte SET status = -1, modif = CURDATE() WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            
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
     * Obține detaliile unei adeverințe specifice
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @return Obiectul Adeverinta sau null dacă nu a fost găsit
     */
    public Adeverinta getAdeverintaById(int idAdeverinta) {
        Adeverinta adeverinta = null;
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a obține detaliile adeverinței
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
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