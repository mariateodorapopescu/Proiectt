package bean;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TimerTask;

public class Testing extends TimerTask
{
	private static Map<String, Long> lastSentMap = new HashMap<>();
	public void run()
	{
		 try {
	            Class.forName("com.mysql.cj.jdbc.Driver");
	            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
	                sendReminders(connection);
	            } catch (IOException e) {
	                System.err.println("Error during database operation: " + e.getMessage());
	            } catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        } catch (ClassNotFoundException e) {
	            System.err.println("MySQL JDBC driver not found: " + e.getMessage());
	        }
				// System.out.println("ok");

	        }
	
	private void sendReminders(Connection connection) throws Exception {
	    String query = "SELECT DISTINCT useri.id, useri.email, concedii.start_c, concedii.end_c, locatie, concedii.motiv, tipcon.motiv AS tip_motiv, DATEDIFF(concedii.start_c, CURRENT_DATE()) AS days_until_start "
	            + "FROM useri "
	            + "JOIN concedii ON useri.id = concedii.id_ang "
	            + "JOIN tipcon ON concedii.tip = tipcon.tip "
	            + "WHERE DATEDIFF(concedii.start_c, CURRENT_DATE()) BETWEEN 0 AND 3 AND concedii.status = 2;";

	    try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
	        ResultSet rs = preparedStatement.executeQuery();
	        while (rs.next()) {
	            sendEmail(rs);
	        }
	    } catch (SQLException e) {
	        throw new IOException("Database query failed: " + e.getMessage(), e);
	    }
	}

	private void sendEmail(ResultSet rs) throws Exception {
		 long currentTimeMillis = System.currentTimeMillis();
		 
	    int id = rs.getInt("id");
	    String to = rs.getString("email");
	    if (lastSentMap.containsKey(to) && (currentTimeMillis - lastSentMap.get(to)) < 3600000) {
            System.out.println(to + " a primit deja un email in ultima ora.");
            return;
        }
	    Date startDate = rs.getDate("start_c");
	    Date endDate = rs.getDate("end_c");
	    int daysUntilStart = rs.getInt("days_until_start"); // Added this line to capture days until start
	    String locatie = rs.getString("locatie");
	    String motiv = rs.getString("motiv");
	    String tipMotiv = rs.getString("tip_motiv");

	    SimpleDateFormat sdf = new SimpleDateFormat("EEEE dd MMMM yyyy", new Locale("ro", "RO"));
	    String formattedStart = sdf.format(startDate);
	    String formattedEnd = sdf.format(endDate);

	    String subject = "Aveti o notificare!";
	    String message1 = "<h1>Aveti un concediu incepand in " + daysUntilStart + " zile!</h1>"; // Modified this line to include days until start
	    String message2 = "Concediul e in perioada " + formattedStart + " - " + formattedEnd + " in " + locatie + " pe motivul " + motiv + " - " + tipMotiv + ". <br>";
	    String message3 = "Va dorim vacanta placuta!<br>";
	    String message = message1 + "<br>" + message2 + "<br>" + message3 + "<br> Conducerea firmei XYZ.";
	    GMailServer sender = new GMailServer(Constants.setFrom, Constants.setPassword);

	    try {
	        sender.send(subject, message, Constants.setFrom, to);
	        lastSentMap.put(to, currentTimeMillis);
	        System.out.println("S-a trimis mail la " + to);
	        //System.out.println("ok");
	    } catch (Exception e) {
	        e.printStackTrace();
	       // System.out.println("NOTok");
	    }  
	    
	}

}