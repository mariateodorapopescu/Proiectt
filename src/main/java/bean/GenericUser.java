package bean;
import java.util.ArrayList;

public class GenericUser implements User{
    // schema/continutul clasei GenericUser:
    //      username, parola, dept = nume departament, departament (un departament are angajati, inclusiv el, e o bucla)
    // functionalitati:
    //      niciuna, ca sa ai cum sa derivezi adminul =))
    private String username, password, dept;
    private Departament departament;
    private int tip = -1; // 0 = director, 1 = tip1, 2 = tip2, 3 = sef_departament, 4 = administrator
    public GenericUser(String username, String password, Departament departament) {
        this.username = username;
        this.password = password;
        this.dept = departament.getNume();
        this.departament = departament;

    }
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
    public Departament getDepartament() {
        return departament;
    }
    public void setDepartament(Departament departament) {
        this.departament = departament;
    }
    public int getTip() {
        return tip;
    }
    public void setTip(int tip) {
        this.tip = tip;
    }
    public String getDept() {
        return dept;
    }
    public void setDept(String dept) {
        this.dept = dept;
    }
    public String toString() {
        String tipp = new String("");
        if (tip == 0) {
            tipp = tipp + "Director";
        } else if (tip == 1) {
            tipp = tipp + "Tip 1";
        } else if (tip == 2) {
            tipp = tipp + "Tip 2";
        } else if (tip == 3) {
            tipp = tipp + "Sef departament";
        } else {
            tipp = tipp + "Administrator";
        }
        if (tip != 4){
            return username + ": " + dept + "; " + "; " + tipp;
        } else {
            return username + ": " + tipp;
        }
    }
    @Override
    public int compareTo(Object o) {
        GenericUser s = (GenericUser) o;
        if (s.getUsername().compareTo(this.getUsername()) > 0) {
            return 1;
        } else if (s.getUsername().compareTo(this.getUsername()) < 0) {
            return -1;
        } else {
            if (s.getDepartament().getNume().compareTo(this.getDepartament().getNume()) > 0) {
                return 1;
            } else if (s.getDepartament().getNume().compareTo(this.getDepartament().getNume()) < 0) {
                return -1;
            } else {
                return 0;
            }
        }
    }
}

