package bean;
import java.io.Serializable;
public class UserView implements Serializable {
    private static final long serialVersionUID = 1;
    private String username;
    private String departament;
    private String tip;
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
	public String getDepartament() {
		return departament;
	}
	public void setDepartament(String departament) {
		this.departament = departament;
	}
	public String getTip() {
		return tip;
	}
	public void setTip(String tip) {
		this.tip = tip;
	}
}
