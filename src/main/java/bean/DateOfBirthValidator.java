package bean;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

public class DateOfBirthValidator {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static boolean validateDateOfBirth(String dob) {
        try {
            // Parse the date
            LocalDate birthDate = LocalDate.parse(dob, FORMATTER);
            LocalDate currentDate = LocalDate.now();

            // Check if age is at least 18 years
            long age = ChronoUnit.YEARS.between(birthDate, currentDate);
            if (age >= 18) {
                return true;
            }
        } catch (DateTimeParseException e) {
            System.err.println("Invalid date format. Please use 'YYYY-MM-DD'.");
        }
        return false;
    }
}
