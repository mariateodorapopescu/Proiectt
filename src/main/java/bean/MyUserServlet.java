package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

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

        try {
            employeeDao.registerEmployee(employee);
            response.sendRedirect("adminok.jsp");
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            response.sendRedirect("err.jsp");
        }
    }
    
}