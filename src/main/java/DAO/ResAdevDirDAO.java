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
 * Clasa DAO pentru gestionarea aprobării adeverințelor de către director
 */
public class ResAdevDirDAO {
    private DataSource dataSource;
    private Connection connection;
    private Statement statement;
    private PreparedStatement preparedStatement;
    private ResultSet resultSet;

    /**
     * Constructor care inițializează conexiunea la baza de date
     */
    public ResAdevDirDAO() {
        // Inițializează sursa de date
      super();
    }

    /**
     * Obține toate adeverințele care au fost aprobate de șef și așteaptă aprobarea directorului
     * 
     * @return Lista de adeverințe care așteaptă aprobarea directorului
     */
    public List<Adeverinta> getAdeverinteApprovedBySef() {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a obține adeverințele cu status 1 (aprobate de șef)
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire, " +
                         "d.nume_dep as departament " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "WHERE a.status = 1 ORDER BY a.modif DESC";
            
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
     * Obține istoricul adeverințelor (toate adeverințele indiferent de status)
     * 
     * @return Lista tuturor adeverințelor
     */
    public List<Adeverinta> getAllAdeverinte() {
        List<Adeverinta> adeverinte = new ArrayList<>();
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a obține toate adeverințele
            String sql = "SELECT a.id, a.tip, a.motiv, a.status, a.creare, a.modif, " +
                         "u.nume, u.prenume, u.id as id_ang, u.id_dep, t.denumire as tip_denumire, " +
                         "d.nume_dep as departament, s.nume_status " +
                         "FROM adeverinte a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN tip_adev t ON a.tip = t.id " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "JOIN statusuri s ON a.status = s.status " +
                         "ORDER BY a.modif DESC";
            
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
     * Aprobă definitiv o adeverință (actualizează statusul la 2 - Aprobat de director)
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
            String sql = "UPDATE adeverinte SET status = 2, modif = CURDATE() WHERE id = ?";
            
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
     * Respinge o adeverință (actualizează statusul la -2 - Respins de director)
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
            String sql = "UPDATE adeverinte SET status = -2, modif = CURDATE() WHERE id = ?";
            
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
     * Obține statistici pentru adeverințe
     * 
     * @return Un obiect care conține numărul de adeverințe grupate pe status
     */
    public AdeverinteStats getAdeverinteStats() {
        AdeverinteStats stats = new AdeverinteStats();
        
        try {
            // Obține conexiunea
            connection = dataSource.getConnection();
            
            // Query pentru a număra adeverințele după status
            String sql = "SELECT status, COUNT(*) as count FROM adeverinte GROUP BY status";
            
            statement = connection.createStatement();
            resultSet = statement.executeQuery(sql);
            
            // Procesare rezultate
            while (resultSet.next()) {
                int status = resultSet.getInt("status");
                int count = resultSet.getInt("count");
                
                switch (status) {
                    case -2:
                        stats.setRespinseDirector(count);
                        break;
                    case -1:
                        stats.setRespinseSef(count);
                        break;
                    case 0:
                        stats.setNeaprobate(count);
                        break;
                    case 1:
                        stats.setAprobateSef(count);
                        break;
                    case 2:
                        stats.setAprobateDirector(count);
                        break;
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Închide resursele
            close();
        }
        
        return stats;
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
     * Clasa pentru statistici despre adeverințe
     */
    public class AdeverinteStats {
        private int neaprobate = 0;
        private int aprobateSef = 0;
        private int aprobateDirector = 0;
        private int respinseSef = 0;
        private int respinseDirector = 0;
        
        // Getteri și setteri
        public int getNeaprobate() {
            return neaprobate;
        }
        
        public void setNeaprobate(int neaprobate) {
            this.neaprobate = neaprobate;
        }
        
        public int getAprobateSef() {
            return aprobateSef;
        }
        
        public void setAprobateSef(int aprobateSef) {
            this.aprobateSef = aprobateSef;
        }
        
        public int getAprobateDirector() {
            return aprobateDirector;
        }
        
        public void setAprobateDirector(int aprobateDirector) {
            this.aprobateDirector = aprobateDirector;
        }
        
        public int getRespinseSef() {
            return respinseSef;
        }
        
        public void setRespinseSef(int respinseSef) {
            this.respinseSef = respinseSef;
        }
        
        public int getRespinseDirector() {
            return respinseDirector;
        }
        
        public void setRespinseDirector(int respinseDirector) {
            this.respinseDirector = respinseDirector;
        }
        
        public int getTotal() {
            return neaprobate + aprobateSef + aprobateDirector + respinseSef + respinseDirector;
        }
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