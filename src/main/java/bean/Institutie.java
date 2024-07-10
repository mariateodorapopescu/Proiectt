package bean;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.TreeSet;

public class Institutie{
    private static Institutie obj = null; //singleton, ai o singura institutie
    private static String name; // hai sa ii dam si un nume
    private TreeSet<Departament> departamente; // hai ca da, da
    private static TreeSet<Administrator> administratori; // hai ca da
    private TreeSet<Angajat> consiliu;
    private TreeSet<Angajat> angajati;
    private Institutie(String name, TreeSet<Departament> departamente, TreeSet<Administrator> administratori, TreeSet<Angajat> consiliu, TreeSet<Angajat> angajati) {
        this.name = name;
        this.departamente = departamente;
        this.administratori = administratori;
        this.consiliu = consiliu;
        this.angajati = angajati;
    }
    public TreeSet<Departament> getDepartamente() {
        return departamente; // I think I'll need this
    }
    public TreeSet<Administrator> getAdministratori() {
        return administratori; // hai ca da
    }
    public static Institutie getInstance(String name, TreeSet<Departament> departamente, TreeSet<Administrator> administratori, TreeSet<Angajat> consiliu, TreeSet<Angajat> angajati) {
        if (obj == null) // singleton
            obj = new Institutie(name, departamente,administratori, consiliu, angajati);
        return obj;
    }

    public TreeSet<Angajat> getConsiliu() {
        return consiliu;
    }

    public void setConsiliu(TreeSet<Angajat> consiliu) {
        this.consiliu = consiliu;
    }

    public TreeSet<Angajat> getAngajati() {
        return angajati;
    }

    public void setAngajati(TreeSet<Angajat> angajati) {
        this.angajati = angajati;
    }
}

