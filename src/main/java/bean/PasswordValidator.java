package bean;

import java.util.regex.Pattern;

public class PasswordValidator {
    
    private static final String PASSWORD_PATTERN =
    		 "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=]).{8,}$";

    private static final Pattern pattern = Pattern.compile(PASSWORD_PATTERN);

    public static boolean validatePassword(String password) {
        if (password == null || !pattern.matcher(password).matches()) {
            return false;
        }
        return hasValidSequences(password);
    }

    private static boolean hasValidSequences(String password) {
        // Check for consecutive or identical adjacent numbers and letters
        for (int i = 0; i < password.length() - 1; i++) {
            char current = password.charAt(i);
            char next = password.charAt(i + 1);

            // Check for consecutive or identical numbers
            if (Character.isDigit(current) && Character.isDigit(next)) {
                if (current == next || Math.abs(current - next) == 1) {
                    return false;  // Adjacent digits are equal or consecutive
                }
            }

            // Check for consecutive or identical letters, considering diacritics
            if (Character.isLetter(current) && Character.isLetter(next)) {
                if (current == next || Math.abs(Character.toLowerCase(current) - Character.toLowerCase(next)) == 1) {
                    return false;  // Adjacent letters are equal or consecutive (case insensitive)
                }
            }
        }
        return true;
    }
}
