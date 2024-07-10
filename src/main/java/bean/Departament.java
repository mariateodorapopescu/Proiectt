package bean;

import java.lang.reflect.Array;
import java.lang.reflect.GenericArrayType;
import java.util.ArrayList;
import java.util.TreeSet;

public class Departament {
    private String nume;
    private Sef sef;
    private TreeSet<Angajat> angajati; // toti sunt la baza Tip2 si apoi sunt variatiuni
    private int total;
    private int plecati;
    public Departament(String nume, Sef sef, TreeSet<Angajat> angajati, int total) {
        this.nume = nume;
        this.sef = sef;
        this.total = total;
        this.angajati = angajati;
        this.plecati = 0;
    }
    public String getNume() {
        return nume;
    }
    public void setNume(String nume) {
        this.nume = nume;
    }
    public Sef getSef() {
        return sef;
    }
    public void setSef(Sef sef) {
        this.sef = sef;
    }
    public TreeSet<Angajat> getAngajati() {
        return angajati;
    }
    public void setAngajati(TreeSet<Angajat> angajati) {
        this.angajati = angajati;
    }
    public int getPlecati() {
        return plecati;
    }
    public void setPlecati() {
//        this.plecati = catiAuPlecat();
    	this.plecati = 0;
    }
    public int getTotal() {
        return total;
    }
    public void setTotal(int total) {
        this.total = total;
    }
    public int catiAuPlecatzi() {
        int nr = 0;
        for (Angajat i : angajati) {
            for (Angajat j : angajati){
                if (i.getUsername().compareTo(j.getUsername()) != 0) {
                    // agajati diferiti
                    for (Concediu k : i.getConcedii()) {
                        if (j.getConcedii().contains(k)) {
                            nr ++;
                            // tre s-o faci pe zile....
                            // si acum ne-am blocat...
                            // na-ti-o buna...
                            // asta presupune ceva complex
                            // dar daca incercam sa nu ne complicam????
                            // sau hai sa facem interogari pe 2 luni??
                            // interogari pe java....
                            // doua luni ca mai ai sincope la chestii
                        }
                    }
                }
            }
//            for (Concediu j : i.getConcedii()) {
//                if (j.getStart().compareTo()) >= 0 || j.getEnd().compareTo(zi) <= 0) {
//                    nr += 1;
//                    break;
//                }
//            }
        }
        return nr;
    }
    public int catiAuPlecatDzi(Data zi) {
        // in cel mai rau caz ii numeri pe toate departamentele pe directori si gen faci suma si suma sa fie at least 2 intr-o zi
        int nr = 0;
        for (Angajat i : angajati) {
            if (i.getTip() == 0) {
                for (Concediu j : i.getConcedii()) {
                    if (j.getStart().compareTo(zi) >= 0 || j.getEnd().compareTo(zi) <= 0) {
                        nr += 1;
                        break;
                    }
                }
            }
        }
        return nr;
    }
}

