package bean;
public class Data implements Comparable{
    private int zi, luna, an;
    public Data(int zi, int luna, int an) {
        this.zi = zi;
        this.luna = luna;
        this.an = an;
    }

    public int getZi() {
        return zi;
    }

    public void setZi(int zi) {
        this.zi = zi;
    }

    public int getLuna() {
        return luna;
    }

    public void setLuna(int luna) {
        this.luna = luna;
    }

    public int getAn() {
        return an;
    }

    public void setAn(int an) {
        this.an = an;
    }
    public String toString() {
        String s = new String("");
        s = s + zi + "." + luna + "." + an;
        return s;
    }
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
    
 // Utility method to convert the Data object to java.util.Date for SQL operations
 		public static java.util.Date toJavaDate(Data data) {
 		    java.util.Calendar cal = java.util.Calendar.getInstance();
 		    cal.set(java.util.Calendar.YEAR, data.getAn());
 		    cal.set(java.util.Calendar.MONTH, data.getLuna() - 1); // Calendar month is zero-based
 		    cal.set(java.util.Calendar.DAY_OF_MONTH, data.getZi());
 		    return cal.getTime();
 		}
}
