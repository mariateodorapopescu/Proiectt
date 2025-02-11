package bean;


import java.io.Serializable;
public class MyUser implements Serializable {
    /**
     * 
     */
    private static final long serialVersionUID = 1;
    private String nume;
    private String prenume;
    private String data_nasterii;
    private String adresa;
    private String email;
    private String telefon;
    private String username;
    private String password;
    private int departament;
    private int tip;
    private String cnp;
    private int id;
    private String culoare;
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
	public int getDepartament() {
		return departament;
	}
	public void setDepartament(int departament) {
		this.departament = departament;
	}
	public int getTip() {
		return tip;
	}
	public void setTip(int tip) {
		this.tip = tip;
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
	public String getData_nasterii() {
		return data_nasterii;
	}
	public void setData_nasterii(String data_nasterii) {
		this.data_nasterii = data_nasterii;
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
	/**
	 * @return the cnp
	 */
	public String getCnp() {
		return cnp;
	}
	/**
	 * @param cnp the cnp to set
	 */
	public void setCnp(String cnp) {
		this.cnp = cnp;
	}
	/**
	 * @return the id
	 */
	public int getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(int id) {
		this.id = id;
	}
	public String getCuloare() {
		// TODO Auto-generated method stub
		return culoare;
	}
	/**
	 * @param culoare the culoare to set
	 */
	public void setCuloare(String culoare) {
		this.culoare = culoare;
	}
}