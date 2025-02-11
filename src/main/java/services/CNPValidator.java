package services;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoField;
import java.util.regex.Pattern;

public class CNPValidator {

    // Coeficienți pentru verificarea cifrei de control
    private static final int[] CONTROL_VALUES = {2, 7, 9, 1, 4, 6, 3, 5, 8, 2, 7, 9};

    public static boolean isValidCNP(String cnp) {
        // 1. Verifică lungimea și formatul numeric
        if (!Pattern.matches("\\d{13}", cnp)) {
        	System.err.println("nu are 13 cifre!");
            return false; // CNP-ul trebuie să conțină exact 13 cifre
        }

        // 2. Extrage componentele CNP-ului
        int sexAndCentury = Character.getNumericValue(cnp.charAt(0));
        int year = Integer.parseInt(cnp.substring(1, 3));
        int month = Integer.parseInt(cnp.substring(3, 5));
        int day = Integer.parseInt(cnp.substring(5, 7));
        int countyCode = Integer.parseInt(cnp.substring(7, 9));
        int controlDigit = Character.getNumericValue(cnp.charAt(12));

        // 3. Determină secolul corect
        int fullYear;
        switch (sexAndCentury) {
            case 1: case 2: fullYear = 1900 + year; break;
            case 3: case 4: fullYear = 1800 + year; break;
            case 5: case 6: fullYear = 2000 + year; break;
            default: return false; // S trebuie să fie între 1 și 6
        }

        // 4. Verifică dacă data este validă
        if (!isValidDate(fullYear, month, day)) {
        	System.err.println("nu e data valida!");
            return false;
        }

        // 5. Verifică codul județului (01-52 + 40-47 pentru București)
        if (!isValidCountyCode(countyCode)) {
        	System.err.println("nu e judet valid!");
            return false;
        }

        // 6. Calculează și verifică cifra de control
        if (!isValidControlDigit(cnp, controlDigit)) {
        	System.err.println("nu e valid!!!");
            return false;
        }

        return true; // CNP valid
    }

    private static boolean isValidDate(int year, int month, int day) {
        try {
            LocalDate.of(year, month, day); // Verifică dacă data e validă
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean isValidCountyCode(int code) {
        return (code >= 1 && code <= 52) || (code >= 40 && code <= 47);
    }

    private static boolean isValidControlDigit(String cnp, int expectedControlDigit) {
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            sum += Character.getNumericValue(cnp.charAt(i)) * CONTROL_VALUES[i];
        }
        int computedDigit = sum % 11;
        if (computedDigit == 10) computedDigit = 1; // Dacă e 10, devine 1
        return computedDigit == expectedControlDigit;
    }
}
