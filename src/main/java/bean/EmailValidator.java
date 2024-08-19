package bean;
import java.util.regex.Pattern;
public class EmailValidator {
	// Pattern-ul asigura ca sirul email incepe cu caractere alfanumerice sau caractere speciale (_+&*-),
	// urmate de grupuri optionale prefixate cu un punct, si include simbolul "@".
	// Dupa simbolul "@", verifica numele de domeniu care poate contine caractere alfanumerice sau cratime,
	// urmate de un punct si se termina cu un sufix de domeniu care trebuie sa fie intre 2 si 7 litere lungime.
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$");

    public static boolean validare(String email) {
        return EMAIL_PATTERN.matcher(email).matches();
    }
}
