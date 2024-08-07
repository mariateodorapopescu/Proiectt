package bean;

import com.email.durgesh.Email;

public class SimpleEmail {

    public static void main(String[] args) {
        System.out.println("Hello, world!");
    }
    
    public static void send(String to, String sub, String msg, final String user, final String pass) {
        try {
            // Assuming Email is a class from com.email.durgesh that handles email operations
            Email email = new Email(user, pass);
            email.setFrom("emailfantoma@xyz.com", "Firma XYZ");
            email.setSubject(sub);
            email.setContent(msg, "text/html");
            email.addRecipient(to);
            email.send();
        } catch (Exception e) {
            e.printStackTrace();    
        }
    }
}
