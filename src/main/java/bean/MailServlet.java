package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Servlet implementation class MailServlet
 */
public class MailServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MailServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SomeDailyJob job = new SomeDailyJob();
        job.run(); // Execute the job manually
        response.getWriter().write("Email send attempt completed. Check logs for details.");
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		// doGet(request, response);
		response.setContentType("text/html; charset=UTF-8");
		PrintWriter out = response.getWriter();
		// select cu toti userii care au concediu in mai putin de 3 zile
		// String to = "";
		String to = request.getParameter("to");
		
		String subject = "Aveti o notificare!";
		
		int id = Integer.parseInt(request.getParameter("id"));
		 try {
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 int dif = -1;
         try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT CASE WHEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) between 0 and 4 THEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) ELSE -1 END AS dif FROM concedii WHERE id_ang = ? order by dif desc limit 1")) {
             preparedStatement.setInt(1, id);
             ResultSet rs = preparedStatement.executeQuery();
             if (!rs.next()) {
                 out.println("<script type='text/javascript'>");
                 out.println("alert('Date introduse incorect sau nu exista date!');");
                 out.println("</script>");
             } else {
                 dif =  rs.getInt("dif");
                 
             }
         }  catch (Exception e) {
             out.println("<script type='text/javascript'>");
             out.println("alert('Eroare la baza de date!');");
             out.println("</script>");
             e.printStackTrace();
         }
		
         String start = "";
         String end = "";
         String motiv = "";
         String locatie = "";
         try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT DATE_FORMAT(start_c,'%d/%m/%Y') as startt, DATE_FORMAT(end_c,'%d/%m/%Y') as endd, locatie, concedii.motiv as motivv, tipcon.motiv as motif FROM concedii join tipcon on concedii.tip = tipcon.tip WHERE id_ang = ?")) {
             preparedStatement.setInt(1, id);
             ResultSet rs1 = preparedStatement.executeQuery();
             if (!rs1.next()) {
                 out.println("<script type='text/javascript'>");
                 out.println("alert('Date introduse incorect sau nu exista date!');");
                 out.println("</script>");
             } else {
            	 end = rs1.getString("endd");
                 start = rs1.getString("startt");
                 locatie = rs1.getString("locatie");
                 motiv = rs1.getString("motif");
             }
         }  catch (Exception e) {
             out.println("<script type='text/javascript'>");
             out.println("alert('Eroare la baza de date!');");
             out.println("</script>");
             e.printStackTrace();
         }
		
		String message1 = "<h1>Aveti un concediu in mai putin de " + dif + " zile!</h1>";
		// redirectare? si cum automatizezi chestia?
		String message2 = "Concediul e in perioada " + start + " - " + end + " in " + locatie + " pe motivul " + motiv + ". <br>";
		String message3 = "Va dorim vacanta placuta!<br>";
		String message = message1 + "<br>" + message2 + "<br>" + message3 + "<br> Conducerea firmei XYZ.";
		String user = "liviaaamp@gmail.com";
		String pass = "rtmz fzcp onhv minb";
		SimpleEmail.send(to, subject, message, user, pass);
		
	}

}
