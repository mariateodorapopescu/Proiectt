package bean;

import java.sql.Date;

/**
 * Clasa care conține detaliile unui utilizator pentru gestionarea CV-ului
 * Folosită pentru a transfera datele utilizatorului între servlet-uri și JSP-uri
 */
public class CVUserDetails {
    private int id;
    private String nume;
    private String prenume;
    private Date dataNasterii;
    private String adresa;
    private String email;
    private String telefon;
    private String username;
    private int idDep;
    private int tip;
    private String culoare;
    private int activ;
    private byte[] profil;
    private int salariuBrut;
    private Integer sporuri;
    private Integer penalizari;
    private Date dataAng;
    private Date dataModif;
    private String denumire; // denumirea poziției/funcției
    private String numeDep;  // numele departamentului
    
    // Constructori
    public CVUserDetails() {
        // Constructor implicit
    }
    
    public CVUserDetails(int id, String nume, String prenume, String email) {
        this.id = id;
        this.nume = nume;
        this.prenume = prenume;
        this.email = email;
    }
    
    // Getteri și setteri
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getNume() {
        return nume;
    }
    
    public void setNume(String nume) {
        this.nume = nume;
    }
    
    public String getPrenume() {
        return prenume;
    }
    
    public void setPrenume(String prenume) {
        this.prenume = prenume;
    }
    
    public Date getDataNasterii() {
        return dataNasterii;
    }
    
    public void setDataNasterii(Date dataNasterii) {
        this.dataNasterii = dataNasterii;
    }
    
    public String getAdresa() {
        return adresa;
    }
    
    public void setAdresa(String adresa) {
        this.adresa = adresa;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getTelefon() {
        return telefon;
    }
    
    public void setTelefon(String telefon) {
        this.telefon = telefon;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public int getIdDep() {
        return idDep;
    }
    
    public void setIdDep(int idDep) {
        this.idDep = idDep;
    }
    
    public int getTip() {
        return tip;
    }
    
    public void setTip(int tip) {
        this.tip = tip;
    }
    
    public String getCuloare() {
        return culoare;
    }
    
    public void setCuloare(String culoare) {
        this.culoare = culoare;
    }
    
    public int getActiv() {
        return activ;
    }
    
    public void setActiv(int activ) {
        this.activ = activ;
    }
    
    public byte[] getProfil() {
        return profil;
    }
    
    public void setProfil(byte[] profil) {
        this.profil = profil;
    }
    
    public int getSalariuBrut() {
        return salariuBrut;
    }
    
    public void setSalariuBrut(int salariuBrut) {
        this.salariuBrut = salariuBrut;
    }
    
    public Integer getSporuri() {
        return sporuri;
    }
    
    public void setSporuri(Integer sporuri) {
        this.sporuri = sporuri;
    }
    
    public Integer getPenalizari() {
        return penalizari;
    }
    
    public void setPenalizari(Integer penalizari) {
        this.penalizari = penalizari;
    }
    
    public Date getDataAng() {
        return dataAng;
    }
    
    public void setDataAng(Date dataAng) {
        this.dataAng = dataAng;
    }
    
    public Date getDataModif() {
        return dataModif;
    }
    
    public void setDataModif(Date dataModif) {
        this.dataModif = dataModif;
    }
    
    public String getDenumire() {
        return denumire;
    }
    
    public void setDenumire(String denumire) {
        this.denumire = denumire;
    }
    
    public String getNumeDep() {
        return numeDep;
    }
    
    public void setNumeDep(String numeDep) {
        this.numeDep = numeDep;
    }
    
    @Override
    public String toString() {
        return "CVUserDetails{" +
                "id=" + id +
                ", nume='" + nume + '\'' +
                ", prenume='" + prenume + '\'' +
                ", email='" + email + '\'' +
                ", idDep=" + idDep +
                ", tip=" + tip +
                '}';
    }
}