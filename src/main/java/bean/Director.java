package bean;
import java.util.TreeSet;

public class Director extends Sef{

    // schema/continutul clasei Sef:
    //      datele de clasa le ai deja de la Sef, nu mai modifici nimic, nu mai adaugi nimic, cu exceptia tipului, dar tre sa mai adaugi
    //      + angajati
    //      + departamente
    // functionalitati:
    //      introd per concediu pers -> ai deja de la Sef, dar tre sa modifici, sa pui variabila in plus ca max 2 directori plecati
    //      view concedii ang -> ai deja de la Sef dar tre sa modifici sa ai ++++ /an tot + /perioada tot
    //      + view ang tip1 si tip2 -> ai deja de la Sef
    //      + rapoarte -> ai deja de la Sef
    //      + view dept
    //      + view ang
    private TreeSet<User> angajati = null;
    private TreeSet<Departament> departamente = null;
    private int tip = 0;
    public Director(String username, String password, Departament departament) {
        super(username, password, departament);
        departamente = new TreeSet<>();
        angajati = new TreeSet<>();
    }
    @Override
    protected boolean checkConcediu(Concediu con) {
        // cam suna a interogare de baza de date
        // tre sa fac diagrame...
        // how do I iterate prin zile???
        // hai ca facem noi manual un vector de zile =)))))
        if (this.nrZile(this.getConcedii()) > 40) {
            return false;
        }
        if (existaVara(this.getConcedii()) && con.getStart().getLuna() >= 6 && con.getStart().getLuna() <= 8){
            return false;
        }
        if (con.getContor() > 21) {
            return false;
        }

        if (this.getDepartament().catiAuPlecatzi() >= 50/100 * this.getDepartament().getTotal()) {
            return false;
        }
        return true;
    }
}
