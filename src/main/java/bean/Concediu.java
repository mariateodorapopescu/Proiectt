package bean;
/**
 * Clasa ce modeleaza un concediu pentru DAO/baza de date
 */
public class Concediu {
	private int id;
	private int id_ang;
	private String inceput;
	private String sfarsit;
	private String motiv;
	private String locatie;
	private int status;
	private int tip;
	private int durata;
	/**
	 * @return id
	 */
	public int getId() {
		return id;
	}
	/**
	 * @param id
	 */
	public void setId(int id) {
		this.id = id;
	}
	/**
	 * @return start
	 */
	public String getInceput() {
		return inceput;
	}
	/**
	 * @param start 
	 */
	public void setInceput(String start) {
		this.inceput = start;
	}
	/**
	 * @return end
	 */
	public String getSfarsit() {
		return sfarsit;
	}
	/**
	 * @param end the end to set
	 */
	public void setSfarsit(String end) {
		this.sfarsit = end;
	}
	/**
	 * @return the motiv
	 */
	public String getMotiv() {
		return motiv;
	}
	/**
	 * @param motiv the motiv to set
	 */
	public void setMotiv(String motiv) {
		this.motiv = motiv;
	}
	/**
	 * @return the locatie
	 */
	public String getLocatie() {
		return locatie;
	}
	/**
	 * @param locatie the locatie to set
	 */
	public void setLocatie(String locatie) {
		this.locatie = locatie;
	}
	/**
	 * @return the status
	 */
	public int getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(int status) {
		this.status = status;
	}
	/**
	 * @return the id_ang
	 */
	public int getId_ang() {
		return id_ang;
	}
	/**
	 * @param id_ang the id_ang to set
	 */
	public void setId_ang(int id_ang) {
		this.id_ang = id_ang;
	}
	/**
	 * @return the tip
	 */
	public int getTip() {
		return tip;
	}
	/**
	 * @param tip the tip to set
	 */
	public void setTip(int tip) {
		this.tip = tip;
	}
	/**
	 * @return the durata
	 */
	public int getDurata() {
		return durata;
	}
	/**
	 * @param durata the durata to set
	 */
	public void setDurata(int durata) {
		this.durata = durata;
	}
}
