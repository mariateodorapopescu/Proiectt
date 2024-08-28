package mix;
import java.util.Random;

public class RandomNumberGenerator {
    public static int generate(){
        Random random = new Random();
        int min = 10000000; // Lowest 8-digit number
        int max = 99999999; // Highest 8-digit number
        int randomNumber = random.nextInt(max - min + 1) + min;
        return randomNumber;
    }
}

