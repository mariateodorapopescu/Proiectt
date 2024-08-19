package bean;
/**
 * Aceasta clasa modeleaza o data, pana sa descopar java.util.date
 */
public class Data implements Comparable<Object>{
    private int zi, luna, an;
    /**
     * Constructor
     * @param zi
     * @param luna
     * @param an
     */
    public Data(int zi, int luna, int an) {
        this.zi = zi;
        this.luna = luna;
        this.an = an;
    }
    /**
     * 
     * @return ziua
     */
    public int getZi() {
        return zi;
    }
    /**
     * Seteaza ziua
     * @param zi
     */
    public void setZi(int zi) {
        this.zi = zi;
    }
    /**
     * 
     * @return numarul lunii
     */
    public int getLuna() {
        return luna;
    }
    /**
     * Seteaza o luna
     * @param luna
     */
    public void setLuna(int luna) {
        this.luna = luna;
    }
    /**
     * 
     * @return un an
     */
    public int getAn() {
        return an;
    }
    /**
     * seteaza anul
     * @param an
     */
    public void setAn(int an) {
        this.an = an;
    }
    /**
     * Pentru a face afisari
     */
    public String toString() {
        String s = new String("");
        s = s + zi + "." + luna + "." + an;
        return s;
    }
    /**
     * Implementarea interfetei comparable, pentru a face comparatii mai usor si poate pentru a folosi in Liste ordonate
     */
    @Override
    public int compareTo(Object o) {
        Data d = (Data)o;
        if (getAn() > d.getAn()) {
            return 1;
        } else if (getAn() < d.getAn()) {
            return -1;
        } else if (getLuna() > d.getLuna()) {
            return 1;
        } else if (getLuna() < d.getLuna()) {
            return -1;
        } else if (getZi() > d.getZi()) {
            return 1;
        } else if (getZi() < d.getZi()) {
            return -1;
        } else {
            return 0;
        }
    }
    
 /**
  * Metoda ce converteste o data din formatul meu in formatul folosit de mysql si de cel implementat in Java
  * @param data
  * @return o data Java
  */
 		public static java.util.Date toJavaDate(Data data) {
 		    java.util.Calendar cal = java.util.Calendar.getInstance();
 		    cal.set(java.util.Calendar.YEAR, data.getAn());
 		    cal.set(java.util.Calendar.MONTH, data.getLuna() - 1); // Calendar month is zero-based
 		    cal.set(java.util.Calendar.DAY_OF_MONTH, data.getZi());
 		    return cal.getTime();
 		}
}
