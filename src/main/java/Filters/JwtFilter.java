package Filters;

import io.jsonwebtoken.Claims;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class JwtFilter implements Filter {
    private final JwtUtil jwtUtil = new JwtUtil();
    
    // Căi publice care nu necesită autentificare
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/login",
        "/register",
        "/public",
        "/OTP",
        "/OTP2",
        "/OTP3",
        "/login.jsp",
        "/otp.jsp",
        "/forgotpass.jsp",
        "/responsive-login-form-main",
        "/assets",
        "/resources"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getServletPath();

        // Debug pentru a vedea path-ul curent
        System.out.println("Current path: " + path);

        // Permitem resursele statice și căile excluse
        if (isStaticResource(path)) {
            System.out.println("Allowing static resource: " + path);
            chain.doFilter(request, response);
            return;
        }

        if (isExcludedPath(path)) {
            System.out.println("Allowing excluded path: " + path);
            chain.doFilter(request, response);
            return;
        }

        // Verificăm sesiunea
        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("No session found, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Verificăm token-ul
        String token = (String) session.getAttribute("token");
        System.out.println("Token found in session: " + (token != null));

        if (token == null) {
            System.out.println("No token found, redirecting to login");
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            if (!jwtUtil.validateToken(token)) {
                System.out.println("Invalid token, redirecting to login");
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            // Token valid, adăugăm claims la request
            Claims claims = jwtUtil.parseToken(token);
            request.setAttribute("claims", claims);
            System.out.println("Valid token for user: " + claims.getSubject());
            
            chain.doFilter(request, response);
        } catch (Exception e) {
            System.out.println("Token processing error: " + e.getMessage());
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    private boolean isStaticResource(String path) {
        return path != null && (
            path.endsWith(".css") ||
            path.endsWith(".js") ||
            path.endsWith(".png") ||
            path.endsWith(".jpg") ||
            path.endsWith(".gif") ||
            path.endsWith(".ico") ||
            path.endsWith(".woff") ||
            path.endsWith(".woff2") ||
            path.endsWith(".ttf") ||
            path.contains("/assets/") ||
            path.contains("/responsive-login-form-main/") ||
            path.contains("/resources/")
        );
    }

    private boolean isExcludedPath(String path) {
        return path != null && EXCLUDED_PATHS.stream()
            .anyMatch(excludedPath -> path.startsWith(excludedPath));
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("JwtFilter initialized");
    }

    @Override
    public void destroy() {
        System.out.println("JwtFilter destroyed");
    }
}