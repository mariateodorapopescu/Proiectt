package bean;
import java.util.regex.Pattern;
public class NameValidator {
    private static final Pattern NAME_PATTERN = Pattern.compile("^[A-Za-z\\s-]+$");

    public static boolean validateName(String name) {
        return NAME_PATTERN.matcher(name).matches();
    }
}
