package bean;

import java.io.Serializable;
import java.util.Date;

/**
 * Clasa bean pentru adeverințe
 */
public class Adeverinta implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int idAngajat;
    private int tip;
    private String motiv;
    private int status;
    private Date creare;
    private Date modif;
    private String mentiuni;
    
    /**
     * Constructor fără parametri
     */
    public Adeverinta() {
    }
    
    /**
     * Constructor cu parametri
     * 
     * @param id ID-ul adeverinței
     * @param idAngajat ID-ul angajatului
     * @param tip Tipul adeverinței
     * @param motiv Motivul adeverinței
     * @param status Status-ul adeverinței
     * @param creare Data creării
     */
    public Adeverinta(int id, int idAngajat, int tip, String motiv, int status, Date creare) {
        this.id = id;
        this.idAngajat = idAngajat;
        this.tip = tip;
        this.motiv = motiv;
        this.status = status;
        this.creare = creare;
    }
    
    /**
     * Constructor complet
     * 
     * @param id ID-ul adeverinței
     * @param idAngajat ID-ul angajatului
     * @param tip Tipul adeverinței
     * @param motiv Motivul adeverinței
     * @param status Status-ul adeverinței
     * @param creare Data creării
     * @param modif Data modificării
     * @param mentiuni Mențiuni
     */
    public Adeverinta(int id, int idAngajat, int tip, String motiv, int status, Date creare, Date modif, String mentiuni) {
        this.id = id;
        this.idAngajat = idAngajat;
        this.tip = tip;
        this.motiv = motiv;
        this.status = status;
        this.creare = creare;
        this.modif = modif;
        this.mentiuni = mentiuni;
    }
    
    // Getteri și setteri
    
    /**
     * @return ID-ul adeverinței
     */
    public int getId() {
        return id;
    }
    
    /**
     * @param id ID-ul adeverinței
     */
    public void setId(int id) {
        this.id = id;
    }
    
    /**
     * @return ID-ul angajatului
     */
    public int getIdAngajat() {
        return idAngajat;
    }
    
    /**
     * @param idAngajat ID-ul angajatului
     */
    public void setIdAngajat(int idAngajat) {
        this.idAngajat = idAngajat;
    }
    
    /**
     * @return Tipul adeverinței
     */
    public int getTip() {
        return tip;
    }
    
    /**
     * @param tip Tipul adeverinței
     */
    public void setTip(int tip) {
        this.tip = tip;
    }
    
    /**
     * @return Motivul adeverinței
     */
    public String getMotiv() {
        return motiv;
    }
    
    /**
     * @param motiv Motivul adeverinței
     */
    public void setMotiv(String motiv) {
        this.motiv = motiv;
    }
    
    /**
     * @return Status-ul adeverinței
     */
    public int getStatus() {
        return status;
    }
    
    /**
     * @param status Status-ul adeverinței
     */
    public void setStatus(int status) {
        this.status = status;
    }
    
    /**
     * @return Data creării
     */
    public Date getCreare() {
        return creare;
    }
    
    /**
     * @param creare Data creării
     */
    public void setCreare(Date creare) {
        this.creare = creare;
    }
    
    /**
     * @return Data modificării
     */
    public Date getModif() {
        return modif;
    }
    
    /**
     * @param modif Data modificării
     */
    public void setModif(Date modif) {
        this.modif = modif;
    }
    
    /**
     * @return Mențiuni
     */
    public String getMentiuni() {
        return mentiuni;
    }
    
    /**
     * @param mentiuni Mențiuni
     */
    public void setMentiuni(String mentiuni) {
        this.mentiuni = mentiuni;
    }
    
    @Override
    public String toString() {
        return "Adeverinta [id=" + id + ", idAngajat=" + idAngajat + ", tip=" + tip + ", motiv=" + motiv + ", status="
                + status + ", creare=" + creare + ", modif=" + modif + ", mentiuni=" + mentiuni + "]";
    }
}