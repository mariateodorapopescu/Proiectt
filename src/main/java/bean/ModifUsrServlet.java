package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.io.IOException;

public class ModifUsrServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String originalUsername = request.getParameter("originalUsername");
        String newUsername = request.getParameter("username");
        String nume = request.getParameter("nume");
        String prenume = request.getParameter("prenume");
        String data_nasterii = request.getParameter("data_nasterii");
        String adresa = request.getParameter("adresa");
        String email = request.getParameter("email");
        String telefon = request.getParameter("telefon");
        int departament = Integer.valueOf(request.getParameter("departament"));
        int tip = Integer.valueOf(request.getParameter("tip"));
        
        if (!NameValidator.validateName(nume)) {
            response.sendRedirect("modifusr2.jsp?n=true");
            return;
        }
        if (!NameValidator.validateName(prenume)) {
            response.sendRedirect("modifusr2.jsp?pn=true");
            return;
        }
        if (!EmailValidator.validateEmail(email)) {
            response.sendRedirect("modifusr2.jsp?e=true");
            return;
        }

        if (!PhoneNumberValidator.validatePhoneNumber(telefon)) {
            response.sendRedirect("modifusr2.jsp?t=true");
            return;
        }

        if (!DateOfBirthValidator.validateDateOfBirth(data_nasterii)) {
            response.sendRedirect("modifusr2.jsp?dn=true");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("UPDATE useri SET nume =?, prenume = ?, data_nasterii = ?, adresa = ?, email = ?, telefon = ?, username = ?, id_dep = ?, tip = ? WHERE username = ?");
            preparedStatement.setString(1, nume);
            preparedStatement.setString(2, prenume);
            preparedStatement.setString(3, data_nasterii);
            preparedStatement.setString(4, adresa);
            preparedStatement.setString(5, email);
            preparedStatement.setString(6, telefon);
            preparedStatement.setString(7, newUsername);
            preparedStatement.setInt(8, departament);
            preparedStatement.setInt(9, tip);
            preparedStatement.setString(10, originalUsername);
            preparedStatement.executeUpdate();

            preparedStatement.close();
            connection.close();
            response.sendRedirect("adminok.jsp"); // Redirect to a confirmation page
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("err.jsp"); // Redirect to an error page
        }
    }
}