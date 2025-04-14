package Filters;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

public class HtmlResponseWrapper extends HttpServletResponseWrapper {
    private final StringWriter stringWriter = new StringWriter();
    private final ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    private ServletOutputStream servletOutputStream = null;
    private PrintWriter writer = null;
    private boolean isUsingWriter = false;

    public HtmlResponseWrapper(HttpServletResponse response) {
        super(response);
    }

    @Override
    public PrintWriter getWriter() throws IOException {
        if (servletOutputStream != null) {
            throw new IllegalStateException("getOutputStream() already called");
        }
        
        if (writer == null) {
            writer = new PrintWriter(stringWriter);
            isUsingWriter = true;
        }
        
        return writer;
    }

    @Override
    public ServletOutputStream getOutputStream() throws IOException {
        if (isUsingWriter) {
            throw new IllegalStateException("getWriter() already called");
        }
        
        if (servletOutputStream == null) {
            servletOutputStream = new CustomServletOutputStream(outputStream);
        }
        
        return servletOutputStream;
    }

    @Override
    public void flushBuffer() throws IOException {
        if (writer != null) {
            writer.flush();
        } else if (servletOutputStream != null) {
            servletOutputStream.flush();
        }
    }

    public String getHtml() {
        if (writer != null) {
            return stringWriter.toString();
        } else if (servletOutputStream != null) {
            return new String(outputStream.toByteArray());
        } else {
            return "";
        }
    }

    private static class CustomServletOutputStream extends ServletOutputStream {
        private final ByteArrayOutputStream outputStream;

        public CustomServletOutputStream(ByteArrayOutputStream outputStream) {
            this.outputStream = outputStream;
        }

        @Override
        public void write(int b) throws IOException {
            outputStream.write(b);
        }

        @Override
        public void write(byte[] b) throws IOException {
            outputStream.write(b);
        }

        @Override
        public void write(byte[] b, int off, int len) throws IOException {
            outputStream.write(b, off, len);
        }

        @Override
        public boolean isReady() {
            return true;
        }

        @Override
        public void setWriteListener(WriteListener writeListener) {
            // Not implemented for this example
        }
    }
}