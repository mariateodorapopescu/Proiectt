package bean;

public class UserFactory {
    public static User factory(int tip, String username, String password, Departament departament) {
        if (tip == 0) {
            return new Director(username, password, departament);
        } else if (tip == 1)
            return new Tip1(username, password, departament);
        if (tip == 2)
            return new Tip2(username, password,departament);
        if (tip == 3)
            return new Sef(username, password, departament);
        if (tip == 4)
            return new Administrator(username, password, departament);
        return null;
    }
}


