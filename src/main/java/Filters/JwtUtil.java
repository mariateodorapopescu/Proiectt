package Filters;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.Date;

public class JwtUtil {
    private static final Key key = Keys.secretKeyFor(SignatureAlgorithm.HS512); // Generează o cheie sigură
    private static final long EXPIRATION_TIME = 864_000_00; // 24 hours

    public String generateToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key, SignatureAlgorithm.HS512)
                .compact();
    }

    public Claims parseToken(String token) {
        // Remove 'Bearer ' if present
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        
        return Jwts.parser()
                .setSigningKey(key)
                .parseClaimsJws(token)
                .getBody();
    }

    public boolean validateToken(String token) {
        try {
            // Remove 'Bearer ' if present
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            
            Jwts.parser()
                .setSigningKey(key)
                .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}