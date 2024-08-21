package bean;
import java.util.Random;

public class RandomColorGenerator {
	
    public static String generate() {
        Random random = new Random();// seed current timestamp + id user
        String color = String.format("#%06x", random.nextInt(0xffffff + 1));
        return color;
    }
}
