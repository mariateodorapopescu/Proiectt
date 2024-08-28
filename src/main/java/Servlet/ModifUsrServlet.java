package Servlet;
import services.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.annotation.MultipartConfig;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
@MultipartConfig(maxFileSize = 16177216) // 1.5 MB
public class ModifUsrServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //String originalUsername = request.getParameter("originalUsername");
		String idd = request.getParameter("id");
		System.out.println(idd);
    	int id = Integer.valueOf(request.getParameter("id"));
    	int id2 = Integer.valueOf(idd);
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
        	if (tip != 4) {
        		response.sendRedirect("despr.jsp?n=true");
		    } else {
		    	response.sendRedirect("signin.jsp?n=true");
		    }
            return;
        }
        if (!NameValidator.validateName(prenume)) {
        	if (tip != 4) {
        		response.sendRedirect("despr.jsp?pn=true");
		    } else {
		    	response.sendRedirect("signin.jsp?pn=true");
		    }
            return;
        }
        if (!EmailValidator.validare(email)) {
        	if (tip != 4) {
        		response.sendRedirect("despr.jsp?e=true");
		    } else {
		    	response.sendRedirect("signin.jsp?e=true");
		    }
            return;
        }

        if (!PhoneNumberValidator.validatePhoneNumber(telefon)) {
        	if (tip != 4) {
        		response.sendRedirect("despr.jsp?t=true");
		    } else {
		    	response.sendRedirect("signin.jsp?t=true");
		    }
            return;
        }

        if (!CheckerDataNasterii.valideaza(data_nasterii)) {
        	if (tip != 4) {
        		response.sendRedirect("despr.jsp?dn=true");
		    } else {
		    	response.sendRedirect("signin.jsp?dn=true");
		    }
            return;
        }
        
        int nrsef = -1;
        int nrdir = -1;
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
      	         PreparedStatement preparedStatement = connection.prepareStatement("select count(*) as total from useri where tip = 0 and id != ? group by id_dep having id_dep = ?;");
        		 PreparedStatement stmt = connection.prepareStatement("select count(*) as total from useri where tip = 3 and id != ? group by id_dep having id_dep = ?;")) {
        	preparedStatement.setInt(2, departament);
        	preparedStatement.setInt(1, id2);
        	stmt.setInt(2, departament);
        	stmt.setInt(1, id2);
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
				 PrintWriter out1 = response.getWriter();
				    out1.println("<script type='text/javascript'>");
				    out1.println("alert('Eroare la baza de date - debug only!');");
				    if (tip != 4) {
				    	out1.println("window.location.href = 'despr.jsp';");
				    } else {
				    out1.println("window.location.href = 'modifdel.jsp';");
				    }
				    out1.println("</script>");
				    out1.close();
				    e.printStackTrace();
		        throw new IOException("Eroare la baza de date =(", e);
		       
		    }
        
        if (tip == 3 && nrsef == 2) {
        	response.sendRedirect("despr.jsp?pms=true");
            return;
        }
        
        if (tip == 0 && nrdir == 2) {
        	response.sendRedirect("despr.jsp?pmd=true");
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
		    if (tip != 4) {
		    	out.println("window.location.href = 'despr.jsp';");
		    } else {
		    out.println("window.location.href = 'modifdel.jsp';");
		    }
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    if (tip != 4) {
		    	out.println("window.location.href = 'despr.jsp';");
		    } else {
		    out.println("window.location.href = 'modifdel.jsp';");
		    }
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
        
        Part filePart = request.getPart("image"); // Retrieves <input type="file" name="image">
        InputStream inputStream = null;
        if (filePart != null) {
            // Obtains input stream of the upload file
            inputStream = filePart.getInputStream();
        }
        Connection conn = null; // connection to the database
        try {
            // Connects to the database
            DriverManager.registerDriver(new com.mysql.cj.jdbc.Driver());
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");

            // Constructs SQL statement
            String sql = "UPDATE useri profil=? WHERE id=?";
            PreparedStatement statement = conn.prepareStatement(sql);

            if (inputStream != null) {
                // Fetches input stream of the upload file for the blob column
                statement.setBlob(1, inputStream);
            }

            int userId = Integer.parseInt(request.getParameter("id")); // Fetch this from your form or session
            statement.setInt(2, userId);

            // Sends the statement to the database server
            int row = statement.executeUpdate();
            if (row > 0) {
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            if (conn != null) {
                // Closes the database connection
                try {
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }  
    }
}