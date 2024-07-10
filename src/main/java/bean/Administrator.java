package bean;

import java.util.ArrayList;
import java.util.SplittableRandom;
import java.util.TreeSet;

public class Administrator extends GenericUser{
    // schema/continutul clasei Administrator:
    //      lista username, parola, dept = nume departament, departament (un departament are angajati) -> le ai de la GenericUser
    // functionalitati:
    //      view concedii ang
    //                      -> /an dept
    //                      -> /an ang
    //                      -> /perioada dept
    //                      -> /perioada ang
    private TreeSet<User> angajati = null;
    UserFactory factory = null;
    private TreeSet<Departament> departamente = null;
    private int tip = 4;
    public Administrator(String username, String password, Departament departament) {
        super(username, password, departament);
        departamente = new TreeSet<>();
        angajati = new TreeSet<>();
        factory = new UserFactory();
    }
    public TreeSet<Departament> getDepartamente() {
        return departamente; // I think I'll need this
    }
    public void vizualizareDepartamente() {
        for (Departament dep : departamente) { // for each
            System.out.print(dep.getNume() + " ");
            // afisarea propriu zis nu stiu cum va fi, deocamdata facem CLI??
        }
    }
    public Departament adaugareDepartament(Departament departament) {
        if (!departamente.contains(departament)) {
            departamente.add(departament);
        }
        return departament;
    }
    public void stergereDepartament(Departament departament) {
        if (departamente.contains(departament)) {
            departamente.remove(departament);
        }
    }
    public void modificareDepartament(Departament departament, Cerere1 cerere) {
        // tu iei cererea de la client si vezi tipul de cerere
        if (departamente.contains(departament)) {
            for (Departament i : departamente) { // verificam concret
                if (i.getNume().compareTo(departament.getNume()) == 0 && i.getTotal() == departament.getTotal() &&
                        i.getSef().compareTo(departament.getSef()) == 0) {
                    if (cerere.getActiune() == 1) {
                        // modifica numele
                        i.setNume(cerere.getContinut());
                    } else if (cerere.getActiune() == 2) {
                        // ii schimba seful
                        String[] elemente = cerere.getContinut().split(";");
                        Sef sefNou = new Sef(elemente[0], elemente[1], departament);
                        i.setSef(sefNou);
                    }
                }
            }
        }
    }
    public Departament creareDepartament(String nume, Sef sef){
        Departament dep = new Departament(nume, sef, new TreeSet<>(),0);
        return dep;
    }
    public void definireDepartament(String nume, Sef sef) {
        adaugareDepartament(creareDepartament(nume, sef));
    }

    public void definireUser(String usernmane, String password, Departament departament, int tip) {
        User genericuser = factory.factory(tip,usernmane,password,departament);
        angajati.add(genericuser);
    }

    public void modificareUser(User angajat, Cerere2 cerere) {
        // tu iei cererea de la client si vezi tipul de cerere
        if (angajati.contains(angajat)) {
            for (User i : angajati) { // verificam concret
                if (i.getUsername().compareTo(angajat.getUsername()) == 0 && i.getDepartament() == angajat.getDepartament()) {
                    if (cerere.getActiune() == 1) {
                        // modifica username
                        i.setUsername(cerere.getContinut());
                    } else if (cerere.getActiune() == 2) {
                        // modifica parola
                        i.setPassword(cerere.getContinut());
                    } else if (cerere.getActiune() == 3) {
                        // modifica departamentul
                        i.setDept(cerere.getContinut());
                        for (Departament d : departamente) {
                            if (d.getNume().compareTo(cerere.getContinut()) == 0) {
                                i.setDepartament(d);
                                break;
                            }
                        }
                    } else if (cerere.getActiune() == 4) {
                        // modifica cu totul
                        // payload-ul vine asa: username;parola;dept
                        String[] elemente = cerere.getContinut().split(";");
                        i.setUsername(elemente[0]);
                        i.setPassword(elemente[1]);
                        i.setDept(elemente[2]);
                        for (Departament d : departamente) {
                            if (d.getNume().compareTo(elemente[2]) == 0) {
                                i.setDepartament(d);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    public void setIerarhie(User angajat, int tip){
        if (angajati.contains(angajat)) {
            angajat.setTip(tip);
        }
    }
    public void setUserDept(User angajat, Departament departament) {
        if (angajati.contains(angajat)) {
            angajat.setDept(departament.getNume());
            angajat.setDepartament(departament);
        }
    }
    public void viewDepartamente() {
        for (Departament d:departamente) {
            System.out.print(d.getNume() + "; ");
        }
    }
    public void viewAngajati() {
        for (User i : angajati) {
            System.out.print(i + "; ");
        }
    }
}
