package bean;

public class Tip1 extends Tip2{
    // schema/continutul clasei Tip1:
    //      datele de clasa le are deja de la Tip2, nu mai adaugi nimic, cu exceptia tipului
    // functionalitati:
    //      ~ introd per concediu pers -> max 40! zile, in rest override Tip2
    //      view concedii ang -> le ai deja de la Tip2
    private int tip = 1;
    public Tip1(String username, String password, Departament departament) {
        super(username, password, departament);
    }
    @Override
    protected boolean checkConcediu(Concediu con) {
        if (this.nrZile(this.getConcedii()) > 40) {
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
