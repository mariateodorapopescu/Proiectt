package bean;

import java.util.ArrayList;

public class Concediu implements Comparable{
    private Data start, end;
    private int contor;
    public Concediu(Data start, Data end) {
        this.start = start;
        this.end = end;
    }

    public Data getStart() {
        return start;
    }

    public void setStart(Data start) {
        this.start = start;
    }

    public Data getEnd() {
        return end;
    }

    public void setEnd(Data end) {
        this.end = end;
    }

    public void setContor() {
        Data startt, endd;
        startt = getStart();
        endd = getEnd();
        if (startt.getLuna() == end.getLuna()) {
            contor = endd.getZi() - startt.getZi() + 1;
        } else {
            if (startt.getLuna() == 1 || startt.getLuna() == 3 || startt.getLuna() == 5 || startt.getLuna() == 7
                    || startt.getLuna() == 8 || startt.getLuna() == 10 || startt.getLuna() == 12) {
                contor = 31 - startt.getZi() + endd.getZi() + 1;
            } else if (startt.getLuna() == 4 || startt.getLuna() == 6 || startt.getLuna() == 9 || startt.getLuna() == 11) {
                contor = 30 - startt.getZi() + endd.getZi() + 1;
            } else {
                if (startt.getAn() % 4 == 0) {
                    contor = 29 - startt.getZi() + endd.getZi() + 1;
                } else {
                    contor = 28 - startt.getZi() + endd.getZi() + 1;
                }
            }
        }
    }

    public int getContor() {
        return contor;
    }
    public String toString() {
        String s = new String("");
        s = s + start + " - " + end;
        return s;
    }
    public ArrayList<Data> interval() {
        ArrayList<Data> zile = new ArrayList<>();
        int zi = start.getZi(), luna = start.getLuna(), an = start.getAn();
        int nr = 0;
        while (nr < contor) {
            if (luna == 1 || luna == 3 || luna == 5 || luna == 7 || luna == 8 || luna == 10 || luna == 12) {
                if (zi + 1 == 32) {
                    zi = 1;
                    if (luna == 12) {
                        luna = 1;
                        an += 1;
                    } else {
                        luna += 1;
                    }
                } else {
                    zi += 1;
                }
            } else if (luna == 4 || luna == 6 || luna == 9 || luna == 11) {
                if (zi + 1 == 31) {
                    zi = 1;
                    luna += 1;
                } else {
                    zi += 1;
                }
            } else if (luna == 2) {
                if (an % 4 == 0) {
                    if (zi + 1 == 30) {
                        luna += 1;
                        zi = 1;
                    } else {
                        zi += 1;
                    }
                } else {
                    if (zi + 1 == 29) {
                        luna += 1;
                        zi = 1;
                    } else {
                        zi += 1;
                    }
                }
            }
            zile.add(new Data(zi, luna, an));
            nr += 1;
        }
        return zile;
    }
    @Override
    public int compareTo(Object o) {
        Concediu c = (Concediu) o;
        if (getContor() > c.getContor()) {
            return 1;
        } else if (getContor() < c.getContor()) {
            return -1;
        } else if (getStart().compareTo(c.getStart()) > 0) {
            return 1;
        }  else if (getStart().compareTo(c.getStart()) < 0) {
            return -1;
        } else if (getEnd().compareTo(c.getEnd()) > 0) {
            return 1;
        } else if (getEnd().compareTo(c.getEnd()) < 0) {
            return -1;
        } else {
            return 0;
        }
    }
}
