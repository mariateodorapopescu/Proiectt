package bean;

public interface User extends Comparable{
    // username, parola, dept = nume departament, apoi departament in sine, tip
    // userul are un array de concedii, change my mind!
    // user ul mai are functie de aia fancy de view cu care faci overload
    // aaaaaaaaaaaaaaaaaa
    // i can do it... you can do it...
    // hai sa facem codul frumos, lizibil
    // schema/continutul clasei administrator
    // lista angajati, lista departamente
    // schema: tip2 < tip1 < sef < director < administrator, unde '<' = include
    // da, dar nu ai extindere multipla, numai interfatare multipla -> User = interfata -> mi-e rau
    String username = null, password = null, dept  = null;
    Departament departament = null;
    int tip = -1; // 0 = director, 1 = tip1, 2 = tip2, 3 = sef_departament, 4 = administrator
    public String getUsername();
    public void setUsername(String username);
    public String getPassword();
    public void setPassword(String password);
    public Departament getDepartament();
    public void setDepartament(Departament departament);
    public void setTip(int tip) ;
    public int getTip();
    public String getDept();
    public void setDept(String dept);
}
