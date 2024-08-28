package mix;
import java.util.Random;

public class RandomColorGenerator {
    
    // Generarea unei culori aleatoare folosind un seed bazat pe timestamp si un identificator unic
    public static String generate(long userId) {
        // Creeaza un obiect Random cu un seed combinat
        Random random = new Random(System.currentTimeMillis() + userId);
        // Genereaza o culoare sub forma de string hexazecimal
        String color = String.format("#%06x", random.nextInt(0xffffff + 1));
        return color;
    }
}
