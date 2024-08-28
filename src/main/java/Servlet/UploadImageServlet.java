package Servlet;
import bean.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import jakarta.servlet.annotation.MultipartConfig;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

//@WebServlet("/UploadImageServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 10,       // 10 MB
    maxRequestSize = 1024 * 1024 * 15     // 15 MB
)
public class UploadImageServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);
        
        
        if (session != null) {
            MyUser currentUser = (MyUser) session.getAttribute("currentUser");
            if (currentUser != null) {
                String username = currentUser.getUsername();
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE username = ?");
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        Part filePart = request.getPart("image");
                        if (filePart != null && filePart.getSize() > 0) {
                            try (InputStream inputStream = filePart.getInputStream()) {
                                String sql = "UPDATE useri SET profil = ? WHERE id = ?";
                                PreparedStatement statement = connection.prepareStatement(sql);
                                statement.setBlob(1, inputStream);
                                statement.setInt(2, userId);
                                int ret = statement.executeUpdate();
                                
                            }
                        } else {
                            ;;
                        }
                    } else {
                        ;;
                    }
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                }
            } else {
                ;;
            }
        }
        
        response.getWriter().println(
        	    "<html><head><title>Upload Status</title></head>" +
        	    "<body onload='window.top.location.reload();'>" + // Folosește eventul onload
        	    
        	    "</body></html>"
        	);

    }
}
