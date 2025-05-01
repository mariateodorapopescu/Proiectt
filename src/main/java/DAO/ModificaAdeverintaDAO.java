package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import bean.Adeverinta;

/**
 * Clasa DAO pentru modificarea adeverințelor
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
     * Obține o adeverință din baza de date
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
            String sql = "SELECT a.id, a.tip, a.motiv, a.pentru_servi, a.status, a.creare, a.modif, " +
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
                
                // Verifică ambele câmpuri și utilizează valoarea non-null
                String motiv = resultSet.getString("pentru_servi");
                if (motiv == null || motiv.trim().isEmpty()) {
                    motiv = resultSet.getString("motiv");
                }
                adeverinta.setMotiv(motiv);
                adeverinta.setMentiuni(motiv); // Folosește aceeași valoare și pentru mențiuni
                
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
     * Modifică o adeverință
     * 
     * @param adeverinta Adeverința cu datele actualizate
     * @return true dacă operația a avut succes, false în caz contrar
     */
    public boolean updateAdeverinta(Adeverinta adeverinta) {
        boolean success = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Query pentru a actualiza adeverința - actualizează ambele câmpuri
            String sql = "UPDATE adeverinte SET tip = ?, motiv = ?, pentru_servi = ?, modif = CURDATE() WHERE id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, adeverinta.getTip());
            
            // Folosește fie motiv, fie mențiuni, în funcție de care nu este null
            String textMotiv = adeverinta.getMotiv();
            if (textMotiv == null || textMotiv.trim().isEmpty()) {
                textMotiv = adeverinta.getMentiuni();
            }
            
            preparedStatement.setString(2, textMotiv); // Actualizează câmpul motiv
            preparedStatement.setString(3, textMotiv); // Actualizează câmpul pentru_servi
            preparedStatement.setInt(4, adeverinta.getId());
            
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
     * Verifică dacă o adeverință poate fi modificată (statusul trebuie să fie 0 pentru utilizatori normali)
     * 
     * @param idAdeverinta ID-ul adeverinței
     * @param idUser ID-ul utilizatorului
     * @param tipUser Tipul utilizatorului
     * @return true dacă adeverința poate fi modificată, false în caz contrar
     */
    public boolean canModifyAdeverinta(int idAdeverinta, int idUser, int tipUser) {
        boolean canModify = false;
        
        try {
            // Obține conexiunea direct prin DriverManager
            connection = getConnection();
            
            // Verifică adeverința și permisiunile utilizatorului
            String sql = "SELECT a.status, a.id_ang, u.id_dep FROM adeverinte a " +
                        "JOIN useri u ON a.id_ang = u.id WHERE a.id = ?";
            
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, idAdeverinta);
            resultSet = preparedStatement.executeQuery();
            
            if (resultSet.next()) {
                int status = resultSet.getInt("status");
                int idAngajat = resultSet.getInt("id_ang");
                int idDepartament = resultSet.getInt("id_dep");
                
                // Verifică permisiunile în funcție de tipul utilizatorului
                if (idAngajat == idUser && status == 0) {
                    // Utilizatorul poate modifica propriile adeverințe neaprobate
                    canModify = true;
                } else if ((tipUser == 3 || (tipUser >= 10 && tipUser <= 15)) && status <= 1) {
                    // Șefii pot modifica adeverințele din departamentul lor
                    // Verifică dacă utilizatorul este șef pentru departamentul angajatului
                    String sqlDep = "SELECT 1 FROM useri WHERE id = ? AND id_dep = ?";
                    PreparedStatement stmtDep = connection.prepareStatement(sqlDep);
                    stmtDep.setInt(1, idUser);
                    stmtDep.setInt(2, idDepartament);
                    ResultSet rsDep = stmtDep.executeQuery();
                    if (rsDep.next()) {
                        canModify = true;
                    }
                    rsDep.close();
                    stmtDep.close();
                } else if (tipUser == 0 || tipUser == 4 || tipUser > 15) {
                    // Directorii și administratorii pot modifica orice adeverință
                    canModify = true;
                }
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