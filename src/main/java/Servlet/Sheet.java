package Servlet;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;

/**
 * Interfața Sheet definește operațiile de bază pentru lucrul cu foi de calcul.
 * Această interfață este inspirată din API-ul Apache POI pentru Excel.
 */
public interface Sheet {
    /**
     * Creează un rând nou la indexul specificat.
     * 
     * @param rowIndex Indexul rândului (începând de la 0)
     * @return Obiectul Row creat
     */
    Row createRow(int rowIndex);
    
    /**
     * Obține un rând existent la indexul specificat.
     * 
     * @param rowIndex Indexul rândului (începând de la 0)
     * @return Obiectul Row sau null dacă rândul nu există
     */
    Row getRow(int rowIndex);
    
    /**
     * Setează lățimea coloanei specificate.
     * 
     * @param columnIndex Indexul coloanei (începând de la 0)
     * @param width Lățimea dorită (în unități specifice)
     */
    void setColumnWidth(int columnIndex, int width);
    
    /**
     * Realizează auto-dimensionarea coloanei specificate.
     * 
     * @param columnIndex Indexul coloanei (începând de la 0)
     */
    void autoSizeColumn(int columnIndex);
    
    /**
     * Obține numele foii de calcul.
     * 
     * @return Numele foii de calcul
     */
    String getSheetName();
    
    /**
     * Setează stilul implicit pentru celule în această foaie.
     * 
     * @param style Stilul ce va fi folosit ca implicit
     */
    void setDefaultColumnStyle(int columnIndex, CellStyle style);
    
    /**
     * Obține numărul ultimului rând din foaia de calcul.
     * 
     * @return Indexul ultimului rând sau -1 dacă foaia este goală
     */
    int getLastRowNum();
    
    /**
     * Adaugă o zonă de protecție pentru foaia de calcul.
     * 
     * @param password Parola pentru protecție
     */
    void protectSheet(String password);
    
    /**
     * Deschide zona de îngheț (freeze pane) la coordonatele specificate.
     * 
     * @param colSplit Numărul de coloane fixate
     * @param rowSplit Numărul de rânduri fixate
     */
    void createFreezePane(int colSplit, int rowSplit);
    
    /**
     * Grupează rândurile specificate.
     * 
     * @param fromRow Rândul de început pentru grupare
     * @param toRow Rândul de final pentru grupare
     */
    void groupRow(int fromRow, int toRow);
}