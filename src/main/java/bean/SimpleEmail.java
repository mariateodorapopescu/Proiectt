package bean;
import java.util.Properties;

import javax.mail.Session;

public class SimpleEmail {
	
	public static void main(String[] args) {
		
	    System.out.println("SimpleEmail Start");
		
	    String smtpHostServer = "smtp.mail.yahoo.com";
	    String emailID = "popescumariateodora@yahoo.com";
	    
	    Properties props = System.getProperties();
	    props.put("mail.smtp.host", smtpHostServer);
	    props.put("mail.smtp.port", 465);
	    //props.put("mail.smtp.host", smtpHostServer);

	    Session session = Session.getInstance(props, null);
	    
	    EmailUtil.sendEmail(session, emailID,"SimpleEmail Testing Subject", "SimpleEmail Testing Body");
	}

}