package bean;

import java.util.TreeSet;

public class Tip2 extends Angajat{
    // schema/continutul clasei Tip2:
    //      date de clasa le ai de la Angajat, nu mai adaugi nimic, cu exceptia tipului
    // functionalitati:
    //      introd per concediu pers la fel ca la Angajat, doar ca ai conditie de -> max 30! zile
    //      view concedii ang -> la fel ca la Angajat
    private int tip;
    private TreeSet<Concediu> concedii = null;
    public Tip2(String username, String password, Departament departament) {
        super(username,password,departament);
        tip = 2;
        concedii = new TreeSet<>();
    }
    @Override
    protected boolean checkConcediu(Concediu con) {
        if (this.nrZile(this.getConcedii()) > 30) {
            return false;
        }
        if (existaVara(this.getConcedii()) && con.getStart().getLuna() >= 6 && con.getStart().getLuna() <= 8){
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
}
