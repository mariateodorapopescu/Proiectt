package bean;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.internet.MimeUtility;

import org.apache.tomcat.jakartaee.commons.lang3.StringEscapeUtils;

import com.email.durgesh.Email;

@SuppressWarnings("deprecation")
public class GMailServer extends javax.mail.Authenticator
{
    private String mailhost ="smtp.gmail.com";
    private String user;
    private String password;
    private Session session;  

    public GMailServer(String user, String password) {
        this.user = user;
        this.password = password;  

        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", "smtp");
        props.setProperty("mail.smtp.host", mailhost);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.socketFactory.port", "465");
        props.put("mail.smtp.socketFactory.class","javax.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.starttls.enable","true");
        props.put("mail.smtp.debug", "true");
        props.put("mail.smtp.socketFactory.fallback", "false");
        props.setProperty("mail.smtp.quitwait", "false");  

        session = Session.getDefaultInstance(props, this);
        session.setDebug(true);
    }  

    protected PasswordAuthentication getPasswordAuthentication()
    {
        return new PasswordAuthentication(user, password);
    }  
    
    public synchronized void sendattach(String subject, String body, String sender, String recipients, String filepath) throws Exception {
    	MimeMessage m = new MimeMessage(session);

		  try {
	          m.setFrom("liviaaamp@gmail.com");
	          m.setSubject(MimeUtility.encodeText(subject, "UTF-8", "B"));
	          m.addRecipient(Message.RecipientType.TO, new InternetAddress(recipients));
	  		
	  		m.setSubject(subject);
	  	
	  		String path=filepath;
	  		
	  		MimeMultipart mimeMultipart = new MimeMultipart();
	  		
	  		MimeBodyPart textMime = new MimeBodyPart();
	  		
	  		MimeBodyPart fileMime = new MimeBodyPart();
	  		
	  		try {
	  			
	  			textMime.setText(body);
	  			
	  			textMime.setContent(body, "text/html; charset=UTF-8");
	  			
	  			File file=new File(path);
	  			fileMime.attachFile(file);
	  			
	  			mimeMultipart.addBodyPart(textMime);
	  			
	  			mimeMultipart.addBodyPart(fileMime);
	  			
	  		} catch (Exception e) {
	  			
	  			e.printStackTrace();
	  		}

	  		m.setContent(mimeMultipart);
	  		
	  		Transport.send(m);
	  		
	  		}catch (Exception e) {
	  			e.printStackTrace();
	  		}
	  		

	  		System.out.println("OK");
}
    
	public synchronized void send(String subject, String body, String sender, String recipients) throws Exception {
		  try {
	          Email email = new Email(user, password);
	          email.setFrom("liviaaamp@gmail.com", "Firma XYZ");
	          email.setSubject(MimeUtility.encodeText(subject, "UTF-8", "B"));
	          email.setContent(StringEscapeUtils.unescapeJava(body), "text/html; charset=UTF-8");
	          email.addRecipient(recipients);
	          email.send();
	      } catch (Exception e) {
	          e.printStackTrace();    
	      }
	}
	
    public synchronized void sendMail(String subject, String body, String sender, String recipients) throws Exception
    {
        MimeMessage message = new MimeMessage(session);
        DataHandler handler = new DataHandler(new ByteArrayDataSource(body.getBytes(), "text/html"));
        message.setSender(new InternetAddress(sender));
        message.setSubject(subject);
        message.setDataHandler(handler);
        if (recipients.indexOf(',') > 0)
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipients));
        else
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipients));
        Transport.send(message);
    }  

    public class ByteArrayDataSource implements DataSource {
        private byte[] data;
        private String type;  
        
        public ByteArrayDataSource(byte[] data, String type) {
            super();
            this.data = data;
            this.type = type;
        }  
        
        public ByteArrayDataSource(byte[] data) {
            super();
            this.data = data;
        }  
        
        public void setType(String type) {
            this.type = type;
        }  

        public String getContentType() {
            if (type == null)
                return "application/octet-stream";
            else
                return type;
        }  

        public InputStream getInputStream() throws IOException {
            return new ByteArrayInputStream(data);
        }  

        public String getName() {
            return "ByteArrayDataSource";
        }  

        public OutputStream getOutputStream() throws IOException {
            throw new IOException("Not Supported");
        }
    }
}