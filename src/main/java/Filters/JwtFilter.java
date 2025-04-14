package Filters;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.*;  // Schimbat din javax în jakarta
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class JwtFilter implements Filter {

    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/login", 
        "/register", 
        "/public",
        "/OTP",
        "/login.jsp",
        "/otp.jsp",
        "/responsive-login-form-main",
        "/assets"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // init method
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        
        String path = request.getServletPath();
        
        // Permitem resursele statice
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Verificăm dacă path-ul este exclus
        if (isExcludedPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        String header = request.getHeader("Authorization");

        if (header == null || !header.startsWith("Bearer ")) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token lipsă sau invalid");
            return;
        }

        String token = header.substring(7); // Remove "Bearer "

        try {
            Claims claims = Jwts.parser()
                    .setSigningKey("secretKeysecretKeysecretKeysecretKey")
                    .parseClaimsJws(token)
                    .getBody();
                    
            request.setAttribute("claims", claims);
            chain.doFilter(req, res);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token invalid");
        }
    }

    private boolean isStaticResource(String path) {
        return path.endsWith(".css") || 
               path.endsWith(".js") || 
               path.endsWith(".png") || 
               path.endsWith(".jpg")
              ;
    }

    private boolean isExcludedPath(String path) {
        return EXCLUDED_PATHS.stream()
            .anyMatch(excludedPath -> path.startsWith(excludedPath));
    }

    @Override
    public void destroy() {
        // destroy method
    }
}