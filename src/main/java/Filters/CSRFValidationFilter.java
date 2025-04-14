package Filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class CSRFValidationFilter implements Filter {
    // List of paths where CSRF validation is required
    private static final List<String> INCLUDED_PATHS = Arrays.asList(
        "/AddAddrUsr.jsp",
        "/AddAddrUsr0.jsp",
        "/addc.jsp",
        "/adddep.jsp",
        "/forgotpass.jsp",
        "/sefok.jsp"
        // Add more paths as needed
    );

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();

        // Continue without CSRF validation for paths not included
        if (!isIncludedPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Perform CSRF token validation for included paths
        validateCsrfToken(httpRequest, httpResponse, path, chain);
    }

    private boolean isIncludedPath(String path) {
        return INCLUDED_PATHS.stream().anyMatch(path::startsWith);
    }

    private void validateCsrfToken(HttpServletRequest httpRequest, HttpServletResponse httpResponse, String path, FilterChain chain)
            throws IOException, ServletException {
        String method = httpRequest.getMethod();
        if ("POST".equalsIgnoreCase(method) || 
            "PUT".equalsIgnoreCase(method) || 
            "DELETE".equalsIgnoreCase(method)) {
            
            HttpSession session = httpRequest.getSession(false);
            if (session == null) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid session");
                return;
            }
            
            String sessionToken = (String) session.getAttribute("csrfToken");
            String requestToken = httpRequest.getParameter("csrfToken");
            if (requestToken == null) {
                requestToken = httpRequest.getHeader("X-CSRF-Token");
            }

            if (sessionToken == null || requestToken == null || !sessionToken.equals(requestToken)) {
                System.out.println("CSRF token invalid: " + requestToken + " vs " + sessionToken);
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token does not match");
                return;
            }
            
            System.out.println("CSRF token valid for " + path);
        }
        
        chain.doFilter(httpRequest, httpResponse);
    }

    @Override
    public void destroy() {}
}
