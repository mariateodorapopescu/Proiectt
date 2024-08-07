package bean;
import java.sql.*;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class SomeDailyJob implements Runnable {
    @Override
    public void run() {
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student")) {
            String query = "SELECT email FROM useri JOIN concedii ON useri.id = concedii.id_ang " +
                           "WHERE DATEDIFF(start_c, CURRENT_DATE()) < 3 AND DATEDIFF(start_c, CURRENT_DATE()) >= 0";
            PreparedStatement stmt = connection.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                sendEmail(rs.getString("email"));
            }
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (MessagingException e) {
            System.err.println("Email sending error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void sendEmail(String to) throws MessagingException {
        String from = "liviaaamp@gmail.com";
        Properties properties = new Properties();
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");  // Use TLS
        properties.put("mail.smtp.user", from);
        properties.put("mail.smtp.password", "rtmz fzcp onhv minb");

        Session session = Session.getInstance(properties, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, "rtmz fzcp onhv minb");
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject("Vacation Reminder!");
        message.setText("Your vacation starts in less than 3 days!");
        Transport.send(message);
    }
}
