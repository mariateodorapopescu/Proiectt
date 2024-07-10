package bean;

public class Sef extends Tip1{
    // schema/continutul clasei Sef:
    //      datele de clasa le ai deja de la Tip1, nu mai modifici nimic, nu mai adaugi nimic, cu exceptia tipului
    // functionalitati:
    //      introd per concediu pers -> ai deja de la Tip1
    //      view concedii ang -> ai deja de la Tip1
    //      + view ang tip1 si tip2
    //      + rapoarte -> TO BE TO...
    private int tip = 3;
    public Sef(String username, String password, Departament departament) {
        super(username, password, departament);
    }
    public void viewAng() {
        // asta cam suna a interogare de baze de date, but still...
        for (Angajat i : this.getDepartament().getAngajati()) {
            if (i.getTip() != 1 && i.getTip() != 4 && i.getTip() != 3) {
                System.out.println(i);
            }
        }
    }
}
