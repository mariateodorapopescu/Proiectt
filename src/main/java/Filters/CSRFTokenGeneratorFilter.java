package Filters;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.math.BigInteger;

public class CSRFTokenGeneratorFilter implements Filter {
    private SecureRandom random = new SecureRandom();

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession();

        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", generateToken());
            System.out.println("S-a generat token pentru form");
        }
        chain.doFilter(request, response);
    }

    private String generateToken() {
        return new BigInteger(130, random).toString(32);
    }

    @Override
    public void destroy() {}
}
