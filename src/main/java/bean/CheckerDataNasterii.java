package bean;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
//importare biblioteci
/**
 * Clasa ce face un obicet verificator
 */
public class CheckerDataNasterii {

    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static boolean valideaza(String zi) throws IOException {
        try {
            // Parsare + declarare si initializare variabile
            LocalDate datanasterii = LocalDate.parse(zi, FORMAT);
            LocalDate datacurenta = LocalDate.now();
            // Verific sa vad daca persoana este majora
            long age = ChronoUnit.YEARS.between(datanasterii, datacurenta);
            if (age >= 18) {
                return true;
            }
        } catch (DateTimeParseException e) {
        	throw new IOException("Format invalid, trebuie AAAA-LL-ZZ", e);
        }
        return false;
    }
}
