package Servlet;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
/**
 * Am incercat sa folosesc aceasta cand mai aveam erori la server la inceput si imi pica serverul
 */
public class ContextFinalizer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ;;
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        AbandonedConnectionCleanupThread.checkedShutdown();
    }
}