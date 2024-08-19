package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.IOException;
import java.io.PrintWriter;

public class ModifUsrServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //String originalUsername = request.getParameter("originalUsername");
    	int id = Integer.valueOf(request.getParameter("id"));
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
        
        int nrsef = -1;
        int nrdir = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
      	         PreparedStatement preparedStatement = connection.prepareStatement("select count(*) as total from useri where tip = 0 and id != ? group by id_dep having id_dep = ?;");
        		 PreparedStatement stmt = connection.prepareStatement("select count(*) as total from useri where tip = 3 and id != ? group by id_dep having id_dep = ?;")) {
        	preparedStatement.setInt(2, departament);
        	preparedStatement.setInt(1, id);
        	stmt.setInt(2, departament);
        	stmt.setInt(1, id);
                  ResultSet rs = preparedStatement.executeQuery();
                  ResultSet res = stmt.executeQuery();
               while (rs.next()) {
                  nrsef = rs.getInt("total");
               }
               while (res.next()) {
                   nrdir = res.getInt("total");
               }
           } catch (SQLException e) {
		        // printSQLException(e);
		        response.setContentType("text/html;charset=UTF-8");
				 PrintWriter out = response.getWriter();
				    out.println("<script type='text/javascript'>");
				    out.println("alert('Eroare la baza de date - debug only!');");
				    out.println("window.location.href = 'modifdel.jsp';");
				    out.println("</script>");
				    out.close();
				    e.printStackTrace();
		        throw new IOException("Eroare la baza de date =(", e);
		       
		    }
        
        if (tip == 3 && nrsef == 1) {
            response.sendRedirect("modifdel.jsp?pms=true");
            return;
        }
        
        if (tip == 0 && nrdir == 1) {
            response.sendRedirect("modifdel.jsp?pmd=true");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("UPDATE useri SET nume =?, prenume = ?, data_nasterii = ?, adresa = ?, email = ?, telefon = ?, username = ?, id_dep = ?, tip = ? WHERE id = ?");
            preparedStatement.setString(1, nume);
            preparedStatement.setString(2, prenume);
            preparedStatement.setString(3, data_nasterii);
            preparedStatement.setString(4, adresa);
            preparedStatement.setString(5, email);
            preparedStatement.setString(6, telefon);
            preparedStatement.setString(7, newUsername);
            preparedStatement.setInt(8, departament);
            preparedStatement.setInt(9, tip);
            //preparedStatement.setString(10, originalUsername);
            preparedStatement.setInt(10, id);
            preparedStatement.executeUpdate();

            preparedStatement.close();
            connection.close();
            response.setContentType("text/html;charset=UTF-8");
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'modifdel.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
    }
}