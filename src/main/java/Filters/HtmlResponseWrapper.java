package Filters;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import java.io.CharArrayWriter;
import java.io.PrintWriter;

public class HtmlResponseWrapper extends HttpServletResponseWrapper {
    private final CharArrayWriter charWriter = new CharArrayWriter();

    public HtmlResponseWrapper(HttpServletResponse response) {
        super(response);
    }

    
	@Override
    public PrintWriter getWriter() {
        return new PrintWriter(charWriter);
    }

    public String getHtml() {
        return charWriter.toString();
    }
}
