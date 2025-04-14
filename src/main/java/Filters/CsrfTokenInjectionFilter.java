package Filters;

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
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Verificăm dacă response-ul este de tip HTML
        String contentType = httpResponse.getContentType();
        if (contentType == null || !contentType.contains("text/html")) {
            // Dacă nu este HTML, nu aplicăm filtrul
            chain.doFilter(request, response);
            return;
        }

        // Aplicăm wrapper-ul doar pentru conținut HTML
        HtmlResponseWrapper responseWrapper = new HtmlResponseWrapper(httpResponse);
        
        chain.doFilter(request, responseWrapper);
        
        String html = responseWrapper.getHtml();
        if (html != null && !html.isEmpty()) {
            // Injectăm token-ul în formularele HTML
            String updatedHtml = injectCsrfToken(html, httpRequest);
            
            // Setăm lungimea corectă a conținutului
            response.setContentLength(updatedHtml.length());
            
            // Trimitem răspunsul modificat
            response.getWriter().write(updatedHtml);
        }
    }

    private String injectCsrfToken(String html, HttpServletRequest request) {
        // Obținem token-ul CSRF din sesiune
        String csrfToken = (String) request.getSession().getAttribute("csrfToken");
        if (csrfToken == null) {
            return html; // Dacă nu există token, returnăm HTML-ul neschimbat
        }

        // Regex pentru a găsi tag-urile de formular și a insera token-ul CSRF
        Pattern pattern = Pattern.compile("<form[^>]*method=['\"]POST['\"][^>]*>", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(html);
        StringBuffer sb = new StringBuffer(html.length());

        while (matcher.find()) {
            System.out.println("CSRF Token injectat în formular");
            String tokenInput = "<input type='hidden' name='csrfToken' value='" + csrfToken + "'/>";
            matcher.appendReplacement(sb, matcher.group() + tokenInput);
        }
        matcher.appendTail(sb);

        return sb.toString();
    }

    @Override
    public void destroy() { }
}