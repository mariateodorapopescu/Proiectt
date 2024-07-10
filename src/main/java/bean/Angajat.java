package bean;

import java.util.TreeSet;

public class Angajat extends GenericUser{
    // schema/continutul clasei Tip2:
    //      date de clasa le ai de la GenericUser, nu mai adaugi nimic, cu exceptia tipului
    // functionalitati:
    //      introd per concediu pers -> o singura data in perioada 01.06-31.08, <= 21 zile, nu mai mult de 50% ang
    //      view concedii ang
    //                      -> /an dept
    //                      -> /an ang
    //                      -> /perioada dept
    //                      -> /perioada ang
    private TreeSet<Concediu> concedii = null;
    public Angajat(String username, String password, Departament departament) {
        super(username,password,departament);
        concedii = new TreeSet<>();
    }
    public TreeSet<Concediu> getConcedii() {
        return concedii;
    }
    public void setConcedii(TreeSet<Concediu> concedii) {
        this.concedii = concedii;
    }
    protected int nrZile(TreeSet<Concediu>concedii){
        int nr = 0;
        for (Concediu i : concedii) {
            nr += i.getContor();
        }
        return nr;
    }
    protected boolean existaVara(TreeSet<Concediu>concedii) {
        for (Concediu c : concedii) {
            if (c.getStart().getLuna() >= 6 || c.getStart().getLuna() <= 8) {
                return true;
            }
        }
        return false;
        // e suficient atata?
    }
    protected boolean checkConcediu(Concediu con) {
        if (existaVara(concedii) && con.getStart().getLuna() >= 6 && con.getStart().getLuna() <= 8){
            return false;
        }
        if (con.getContor() > 21) {
            return false;
        }
//        if (this.getDepartament().catiAuPlecat() >= 50/100 * this.getDepartament().getTotal()) {
//            return false;
//        }
        return true;
    }
    public boolean setConcediu(Data start, Data end) {
        Concediu genericConcediu = new Concediu(start, end);
        genericConcediu.setContor();
        if (!checkConcediu(genericConcediu)) {
            return false;
        }
        concedii.add(genericConcediu);
        return true;
    }
    public void viewConcedii(Cerere3 cerere) {
        if (cerere.getActiune() == 1) {
            // daca vrea pe tot anul, pe departament
            for (Angajat i : this.getDepartament().getAngajati()){
                if (i.getTip() != 0 && i.getTip() != 4) {
                    System.out.print(i.getUsername() + ": ");
                    for (Concediu j : i.getConcedii()) {
                        System.out.print(j + "; ");
                    }
                    System.out.println("");
                }
            }
        } else if (cerere.getActiune() == 2) {
            // daca vrea pe angajat
            for (Angajat i : this.getDepartament().getAngajati()){
                if (i.getTip() != 0 && i.getTip() != 4 && i.getUsername().compareTo(cerere.getContinut())==0) {
                    System.out.print(i.getUsername() + ": ");
                    for (Concediu j : i.getConcedii()) {
                        System.out.print(j + "; ");
                    }
                    System.out.println("");
                    break;
                }
            }
        } else if (cerere.getActiune() == 3) {
            // daca vrea pe o anumita PERIOADA si pentru un anumit angajat
            // continutul suna asa: zis;lunas;ans;zie;lunae;ane (s = start, e = end)
            String[] elemente = cerere.getContinut().split(";");
            int zis = -1, lunas = -1, ans = -1, zie = -1, lunae = -1, ane = -1;
            try {
                zis = Integer.parseInt(elemente[0]);
            } catch (NumberFormatException e) {
                zis = 0;
            }
            try {
                lunas = Integer.parseInt(elemente[1]);
            } catch (NumberFormatException e) {
                lunas = 0;
            }
            try {
                ans = Integer.parseInt(elemente[2]);
            } catch (NumberFormatException e) {
                ans = 0;
            }
            try {
                zie = Integer.parseInt(elemente[3]);
            } catch (NumberFormatException e) {
                zie = 0;
            }
            try {
                lunae = Integer.parseInt(elemente[4]);
            } catch (NumberFormatException e) {
                lunae = 0;
            }
            try {
                ane = Integer.parseInt(elemente[5]);
            } catch (NumberFormatException e) {
                ane = 0;
            }
            Data newDatas = new Data(zis, lunas, ans);
            Data newDatae = new Data(zie, lunae, ane);
            for (Angajat i : this.getDepartament().getAngajati()) {
                if (i.getTip() != 0 && i.getTip() != 4) {
                    System.out.print(i.getUsername() + ": ");
                    for (Concediu j : i.getConcedii()) {
                        if (j.getStart().compareTo(newDatas) >= 0 || j.getEnd().compareTo(newDatae) <= 0) {
                            System.out.print(j + "; ");
                        }
                    }
                    System.out.println("");
                }
            }
        } else {
            // daca vrea pe o anumita PERIOADA si pe un anumit angajat
            // continutul e astfel: zis;lunas;ans;zie;lunae;ane;username
            String[] elemente = cerere.getContinut().split(";");
            int zis = -1, lunas = -1, ans = -1, zie = -1, lunae = -1, ane = -1;
            try {
                zis = Integer.parseInt(elemente[0]);
            } catch (NumberFormatException e) {
                zis = 0;
            }
            try {
                lunas = Integer.parseInt(elemente[1]);
            } catch (NumberFormatException e) {
                lunas = 0;
            }
            try {
                ans = Integer.parseInt(elemente[2]);
            } catch (NumberFormatException e) {
                ans = 0;
            }
            try {
                zie = Integer.parseInt(elemente[3]);
            } catch (NumberFormatException e) {
                zie = 0;
            }
            try {
                lunae = Integer.parseInt(elemente[4]);
            } catch (NumberFormatException e) {
                lunae = 0;
            }
            try {
                ane = Integer.parseInt(elemente[5]);
            } catch (NumberFormatException e) {
                ane = 0;
            }
            Data newDatas = new Data(zis, lunas, ans);
            Data newDatae = new Data(zie, lunae, ane);
            for (Angajat i : this.getDepartament().getAngajati()) {
                if (i.getTip() != 0 && i.getTip() != 4 && i.getUsername().compareTo(elemente[5]) == 0) {
                    System.out.print(i.getUsername() + ": ");
                    for (Concediu j : i.getConcedii()) {
                        if (j.getStart().compareTo(newDatas) >= 0 || j.getEnd().compareTo(newDatae) <= 0) {
                            System.out.print(j + "; ");
                        }
                    }
                    System.out.println("");
                }
            }
        }
    }
}
