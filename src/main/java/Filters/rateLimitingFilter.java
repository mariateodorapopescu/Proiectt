package Filters;

import redis.clients.jedis.Jedis;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class rateLimitingFilter implements Filter {
    private Jedis jedis;
    private final int MAX_REQUESTS_PER_SECOND = 13; // Limit each IP to 10 requests per second

    @Override
    public void init(FilterConfig filterConfig) {
        jedis = new Jedis("localhost", 6379); // Connect to the Redis server
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String clientIp = httpRequest.getRemoteAddr();
        String redisKey = "rate_limit:" + clientIp;

        // Increment the counter in Redis
        long requestCount = jedis.incr(redisKey);
        if (requestCount == 1) { // Set the key to expire after 1 second on the first request
            jedis.expire(redisKey, 1);
        }

        if (requestCount > MAX_REQUESTS_PER_SECOND) {
            httpResponse.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            httpResponse.getWriter().write("Too many requests");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        if (jedis != null) {
            jedis.close();
        }
    }
}
