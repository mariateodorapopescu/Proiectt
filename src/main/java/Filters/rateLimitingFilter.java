package Filters;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.TimeUnit;

public class rateLimitingFilter implements Filter {
    private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
    private final int MAX_REQUESTS_PER_SECOND = 10; // Limit each IP to 10 requests per second

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String clientIp = httpRequest.getRemoteAddr();
        requestCounts.putIfAbsent(clientIp, new AtomicInteger(0));

        if (requestCounts.get(clientIp).incrementAndGet() > MAX_REQUESTS_PER_SECOND) {
            httpResponse.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
            httpResponse.getWriter().write("Too many requests");
            return;
        }

        chain.doFilter(request, response);

        // Reset the count every second
        requestCounts.get(clientIp).decrementAndGet();
    }

    @Override
    public void destroy() {
        requestCounts.clear();
    }
}
