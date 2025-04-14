package Filters;

import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class TokenBlacklist {
    private static Set<String> blacklistedTokens = Collections.newSetFromMap(new ConcurrentHashMap<>());

    public static void blacklistToken(String token) {
        blacklistedTokens.add(token);
    }

    public static boolean isTokenBlacklisted(String token) {
        return blacklistedTokens.contains(token);
    }
}
