package Filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import java.io.IOException;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CsrfTokenInjectionFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HtmlResponseWrapper responseWrapper = new HtmlResponseWrapper((HttpServletResponse) response);

        chain.doFilter(request, responseWrapper);

        String html = responseWrapper.getHtml();
        String updatedHtml = injectCsrfToken(html, httpRequest);

        response.getWriter().write(updatedHtml);
    }

    private String injectCsrfToken(String html, HttpServletRequest request) {
        // Retrieve the CSRF token from the session
        String csrfToken = (String) request.getSession().getAttribute("csrfToken");

        // Regex to find form tags and insert the CSRF token as a hidden input
        Pattern pattern = Pattern.compile("<form[^>]*method=['\"]POST['\"][^>]*>", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(html);
        StringBuffer sb = new StringBuffer(html.length());

        while (matcher.find()) {
        	System.out.println("Fac ceva");
            String tokenInput = "<input type='hidden' name='csrfToken' value='" + csrfToken + "'/>";
            matcher.appendReplacement(sb, matcher.group() + tokenInput);
        }
        matcher.appendTail(sb);

        return sb.toString();
    }

    @Override
    public void destroy() { }
}
