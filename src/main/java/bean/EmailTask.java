package bean;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailTask implements Runnable {

    private String host = "smtp.mail.yahoo.com";
    private String from = "sciencepc@yahoo.com";
    private String username = "sciencepc@yahoo.com";
    private String password = "leontinpopescu";

    @Override
    public void run() {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", "587");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            String query = "SELECT email FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE DATEDIFF(start_c, CURDATE()) <= 3";
            List<String> emailList = new ArrayList<>();
            try (PreparedStatement stmt = con.prepareStatement(query);
                 ResultSet rs2 = stmt.executeQuery()) {
                while (rs2.next()) {
                    emailList.add(rs2.getString("email"));
                }
            }
            
            if (!emailList.isEmpty()) {
                for (String recipient : emailList) {
                    sendEmail(session, recipient);
                }
            }
        } catch (SQLException | MessagingException e) {
            e.printStackTrace();
        }
    }

    private void sendEmail(Session session, String recipient) throws MessagingException {
        String subject = "Notificare";
        String content = "Buna ziua!\n Aveti mai putin de 3 zile pana la concediu! ;) \n Va dorim concediu placut!";

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient));
        message.setSubject(subject);
        message.setText(content);

        Transport.send(message);
    }
}
