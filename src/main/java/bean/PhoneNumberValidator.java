package bean;

import java.util.regex.Pattern;

public class PhoneNumberValidator {
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?(\\d{1,3})?[- .]?\\d{7,10}$");

    public static boolean validatePhoneNumber(String phoneNumber) {
        return PHONE_PATTERN.matcher(phoneNumber).matches();
    }
}
