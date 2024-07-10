package bean;

public class Cerere3 {
    private int actiune;
    private String continut;
    public Cerere3(int actiune, String continut) {
        this.actiune = actiune;
        this.continut = continut;
    }

    public int getActiune() {
        return actiune;
    }

    public void setActiune(int actiune) {
        this.actiune = actiune;
    }

    public String getContinut() {
        return continut;
    }

    public void setContinut(String continut) {
        this.continut = continut;
    }
}

