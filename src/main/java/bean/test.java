package bean;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

// @WebServlet("/test")
public class test extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SomeDailyJob job = new SomeDailyJob();
        job.run();  // Manually running the job for testing
        response.getWriter().write("Email sending job triggered manually.");
    }
}
