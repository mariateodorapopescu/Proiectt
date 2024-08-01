package bean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.w3c.dom.Document;

//import com.itextpdf.pdf2data

import java.sql.PreparedStatement;
import java.sql.ResultSet;

@MultipartConfig
public class UploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("In doPost method of UploadServlet.");
        
        Part filePart = request.getPart("image");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString(); // Sanitizes the file name
        String uploadPath = getServletContext().getRealPath("") + "images" + java.io.File.separator + fileName;
        
        System.out.println("Upload Path : " + uploadPath);

        // Upload the file
        try (InputStream fileContent = filePart.getInputStream();
             FileOutputStream fos = new FileOutputStream(uploadPath)) {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = fileContent.read(buffer)) != -1) {
                fos.write(buffer, 0, read);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Store image name in database
      
        try ( Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement stmt = connection.prepareStatement("INSERT INTO image (imageFileName) VALUES (?)")) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            stmt.setString(1, fileName);
            int row = stmt.executeUpdate();
            if (row > 0) {
                System.out.println("Image added to database successfully.");
            } else {
                System.out.println("Failed to upload image.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
