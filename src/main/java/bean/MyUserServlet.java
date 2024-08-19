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
import java.sql.SQLException;

@WebServlet("/register")
public class MyUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1;
    private MyUserDao employeeDao;

    public void init() {
        employeeDao = new MyUserDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    	
    	String nume = request.getParameter("nume");
    	String prenume = request.getParameter("prenume");
    	String data_nasterii = request.getParameter("data_nasterii");
    	String adresa = request.getParameter("adresa");
    	String email = request.getParameter("email");
    	String telefon = request.getParameter("telefon");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        int dep = Integer.valueOf(request.getParameter("departament"));
        int tip = Integer.valueOf(request.getParameter("tip"));
        int id = RandomNumberGenerator.generate();

        MyUser employee = new MyUser();
        employee.setNume(nume);
        employee.setPrenume(prenume);
        employee.setData_nasterii(data_nasterii);
        employee.setAdresa(adresa);
        employee.setEmail(email);
        employee.setTelefon(telefon);
        employee.setUsername(username);
        employee.setPassword(password);
        employee.setDepartament(dep);
        employee.setTip(tip);
        employee.setCnp(id);
        
        if (!PasswordValidator.validatePassword(password)) {
            response.sendRedirect("signin.jsp?p=true");
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
       // username ul e unic
        int nrsef = -1;
        int nrdir = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
      	         PreparedStatement preparedStatement = connection.prepareStatement("select count(*) as total from useri where tip = 3 and username != ? group by id_dep having id_dep = ?;");
        		 PreparedStatement stmt = connection.prepareStatement("select count(*) as total from useri where tip = 0 and username != ? group by id_dep having id_dep = ?;")) {
        	preparedStatement.setInt(2, dep);
        	preparedStatement.setString(1, username);
        	stmt.setInt(2, dep);
        	stmt.setString(1, username);
                  ResultSet rs = preparedStatement.executeQuery();
                  ResultSet res = stmt.executeQuery();
               while (rs.next()) {
                  nrsef = rs.getInt("total");
               }
               while (res.next()) {
                   nrdir = res.getInt("total");
               }
           } catch (SQLException e) {
		        //printSQLException(e);
		        response.setContentType("text/html;charset=UTF-8");
				 PrintWriter out = response.getWriter();
				    out.println("<script type='text/javascript'>");
				    out.println("alert('Eroare la baza de date - debug only!');");
				    out.println("window.location.href = 'signin.jsp';"); 
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
		        throw new IOException("Eroare la baza de date", e);
		    }
        
        if (tip == 3 && nrsef == 1) {
            response.sendRedirect("signin.jsp?pms=true");
            return;
        }
        
        if (tip == 0 && nrdir == 1) {
            response.sendRedirect("signin.jsp?pmd=true");
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