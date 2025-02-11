package Servlet;
import DAO.*;
import mail.*;
import mix.RandomColorGenerator;
import mix.RandomNumberGenerator;
import bean.*;
import services.*;
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
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Pattern;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/register")
public class MyUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1;
    private MyUserDao employeeDao;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    
    public void init() {
        employeeDao = new MyUserDao();
    }
    
    //  Verificare optimizată a existenței username-ului
    private static boolean usernameExists(Connection connection, String username) throws SQLException {
        String query = "SELECT 1 FROM useri WHERE username = ? LIMIT 1"; //  Limităm rezultatele la 1
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next(); //  Returnează `true` dacă există, `false` dacă nu
            }
        }
    }

    public static String generareUsername(String nume, String prenume, String data_nasterii) {
        //  Evităm adăugarea recursivă în listă
        List<String> potentialUsernames = new ArrayList<>();
        
        //  Construim nume fără să creștem lista exponențial
        potentialUsernames.add(formatUsername(prenume, nume, null));
        if (prenume.contains("-")) {
            potentialUsernames.add(formatUsername(prenume.split("-")[1], nume, null));
        }
        
        //  Adăugăm variante cu data nașterii
        String zzll = data_nasterii.substring(8, 10) + data_nasterii.substring(5, 7);  // ZZLL
        String zzllaa = zzll + data_nasterii.substring(2, 4);  // ZZLLAA
        potentialUsernames.add(formatUsername(prenume, nume, zzll));
        potentialUsernames.add(formatUsername(prenume, nume, zzllaa));

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            for (String username : potentialUsernames) {
                if (!usernameExists(connection, username)) {
                    return username;
                }
            }

            //  Dacă toate variantele sunt ocupate, adăugăm un număr incremental (până la 99)
            String baseUsername = potentialUsernames.get(potentialUsernames.size() - 1);
            for (int counter = 2; counter < 100; counter++) {
                String newUsername = baseUsername + counter;
                if (!usernameExists(connection, newUsername)) {
                    return newUsername;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        //  Fallback final (dacă toate numele sunt ocupate)
        return "user" + System.currentTimeMillis();
    }

    //  Funcție auxiliară pentru a formata username-ul
    private static String formatUsername(String prenume, String nume, String extra) {
        String base = prenume.split("-")[0] + "." + nume.split("-")[0];  // Evităm split necontrolat
        return (extra != null) ? base + extra : base;
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    	
    	String nume = request.getParameter("nume");
    	String prenume = request.getParameter("prenume");
    	String data_nasterii = request.getParameter("data_nasterii");
    	// String adresa = request.getParameter("data_nasterii"); // nu mai am nevoie de asta
    	String email = request.getParameter("email"); // email personal, ca sa poata primi prin mail instructiuni utilizare platforma -> vei avea in bd o coloana cu email personal =))
    	String telefon = request.getParameter("telefon"); // telefon de serviciu are numai hr ul, dar asta hai ca e prea specific asa ca da 
        // String username = request.getParameter("username"); // asta o sa l generezi tu
        // String password = request.getParameter("password"); // asta by default faci un TFRiD2024:) pe care toata lumea tre sa l schimbe la first use sau ceva 
    	// -> faci un compare cu TFRiD2024:) si daca are parola asta il pui sa si-o schimbe =))
    	String password = "TFRiD2024:)"; // se incadreaza in standard, adica 
    	// minim o litera mare, minim o litera mica, minim un caractrer special, minim o cifra, cifre si litere neconsecutive, lungime minima de 8 caractere
        int dep = Integer.valueOf(request.getParameter("departament"));
        int tip = Integer.valueOf(request.getParameter("rang"));
        int pozitie = Integer.valueOf(request.getParameter("pozitie"));
        String cnp = request.getParameter("cnp");
        int id = RandomNumberGenerator.generate();
        String culoare = RandomColorGenerator.generate(id);
        String username = new String(generareUsername(nume, prenume, data_nasterii));
        MyUser employee = new MyUser();
        employee.setNume(nume);
        employee.setPrenume(prenume);
        employee.setData_nasterii(data_nasterii);
       // employee.setAdresa(adresa);
        employee.setEmail(email);
        employee.setTelefon(telefon);
        employee.setUsername(username);
        employee.setPassword(password);
        employee.setDepartament(dep);
        employee.setTip(tip);
        employee.setCnp(cnp);
        employee.setCuloare(culoare);
        /* 
        if (!PasswordValidator.validatePassword(password)) {
            response.sendRedirect("signin.jsp?p=true");
            return;
        }
        */
        if (!CNPValidator.isValidCNP(cnp)) {
            response.sendRedirect("signin.jsp?cnp=true");
            return;
        }
        if (!NameValidator.validateName(nume)) {
            response.sendRedirect("signin.jsp?n=true");
            return;
        }
        if (!NameValidator.validateName(prenume)) {
            response.sendRedirect("signin.jsp?pn=true");
            return;
        }
        if (!EmailValidator.validare(email)) {
            response.sendRedirect("signin.jsp?e=true");
            return;
        }

        if (!PhoneNumberValidator.validatePhoneNumber(telefon)) {
            response.sendRedirect("signin.jsp?t=true");
            return;
        }

        if (!CheckerDataNasterii.valideaza(data_nasterii)) {
            response.sendRedirect("signin.jsp?dn=true");
            return;
        }
       
        try {
            employeeDao.registerEmployee(employee);
            
         // trimit notificare la angajat
            
            GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
            String to = "";
           
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select email from useri where id_dep = ? and username != ?;"
       	         		+ "")) {
       	        stmt.setInt(1, dep);
       	        stmt.setString(2, username); 
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	        	while (rs.next()) {
       	        		to = rs.getString("email");
           	            

        	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
        	    	    String message11 = "<h1>Ultimile noutati </h1>"; 
        	    	    String message12 = "<h2>Avem un nou coleg de departament si anume pe " + nume + " " + prenume + "! </h2>"; 
        	    	    
        	    	    String message16 = "<p>Sa-i uram bun venit si sa facem cunostinta cu aceasta persoana. &#x1F609;\r\n"
        	    	    		+ " <br> Doar suntem o familie! &#x1F917;\r\n"
        	    	    		+ " <br> Va dorim toate cele bune! &#x1F607; \r\n"
        	    	    		+ " </p>";
        	    	    String message1 = message11 + message12 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
        	    	    		+ "</i></b>";
        	    	   
        	    	    try {
        	    	        sender.send(subject1, message1, "liviaaamp@gmail.com", to);
        	    	       
        	    	    } catch (Exception e) {
        	    	        e.printStackTrace();
        	    	       
        	    	    }  
                    
       	        	}
       	            
       	        }
       	    } catch (SQLException e) {
       	        throw new ServletException("Eroare BD =(", e);
       	    } 
            
            String subject1 = "Bun venit in companie!";
    	    String message11 = "<h1>Ne bucuram sa va avem in echipa noastra! =) </h1>"; 
    	    String message12 = "<h2>Ne face placere de cunostinta! Mult succes in continuare! </h2>"; 
    	    String message13 = "<h3>Date de conectare: </h3> <p> <b>Nume de utilizator: </b>" + username + "<br><b>Parola: </b>" + password + "<br></p>";
    	    String message16 = "<p>Mai jos aveti atasat un scurt ghid de utilizare al platfomei. =) <br> Va dorim toate cele bune! &#x1F607; \r\n"
    	    		+ " </p>";
    	    String message1 = message11 + message12 + message13 + message16 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
    	    		+ "</i></b>";
    	   
    	    try {
    	        sender.sendattach(subject1, message1, "liviaaamp@gmail.com", email, "C:\\Users\\Popi\\eclipse-workspace\\Proiect\\ghid.pdf");
    	       
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	       
    	    }  
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	System.out.println("NOT OK");
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut adauga din motive necunoscute.');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    
}