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

import bean.MyUserDao;
import bean.MyUser;

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
        if (!EmailValidator.validateEmail(email)) {
            response.sendRedirect("signin.jsp?e=true");
            return;
        }

        if (!PhoneNumberValidator.validatePhoneNumber(telefon)) {
            response.sendRedirect("signin.jsp?t=true");
            return;
        }

        if (!DateOfBirthValidator.validateDateOfBirth(data_nasterii)) {
            response.sendRedirect("signin.jsp?dn=true");
            return;
        }
        
        int nrsef = -1;
        int nrdir = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
      	         PreparedStatement preparedStatement = connection.prepareStatement("select count(*) as total from useri where tip = 3 group by id_dep having id_dep = ?;");
        		 PreparedStatement stmt = connection.prepareStatement("select count(*) as total from useri where tip = 0 group by id_dep having id_dep = ?;")) {
        	preparedStatement.setInt(1, dep);
        	stmt.setInt(1, dep);
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
				    out.println("window.location.href = 'dashboard.jsp';");
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
		        throw new IOException("Eroare la baza de date =(", e);
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
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'adminok.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut adauga din motive necunoscute.');");
		    out.println("window.location.href = 'dashboard.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
    
}