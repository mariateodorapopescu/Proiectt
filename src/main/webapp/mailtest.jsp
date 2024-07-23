<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<%
    String result;

    final String username = "iamelsapop@gmail.com";
    final String password = "TFRiD2015:)"; // Consider using environment variables for security.

    Properties props = new Properties();
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.port", "587");

    Session s = Session.getInstance(props, new javax.mail.Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(username, password);
        }
    });

    try {
        MimeMessage message = new MimeMessage(s);
        message.setFrom(new InternetAddress(username));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress("liviaaamp@gmail.com"));
        message.setSubject("Test Subject");
        message.setText("Hello, world!"); // Use setText for plain text messages.

        Transport.send(message);
        result = "Sent message successfully....";
    } catch (MessagingException mex) {
        result = "Error: unable to send message...." + mex.getMessage();
        mex.printStackTrace();
    }
%>

<html>
<head>
    <title>Send Email using JSP</title>
</head>
<body>
    <h1>Email Sending Status</h1>
    <p><%= result %></p>
</body>
</html>
