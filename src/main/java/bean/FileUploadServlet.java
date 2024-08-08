package bean;

import java.io.IOException;
import java.io.InputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@MultipartConfig(maxFileSize = 16177215) // upload file's size up to 16MB)
// acesta este un feature de care ne vom ocupa putin mai tarziu . hai sa facem aia cu otp-ul
// otp la schimbare parola si otp la schimbare date user in loc sa i mai trimita la forgotpass
public class FileUploadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FileUploadDao fileUploadDao;

    @Override
    public void init() {
        fileUploadDao = new FileUploadDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Get values of text fields
        String uid = request.getParameter("id");
        int id = -1;
        if (uid != null && !uid.isEmpty()) {
            try {
                id = Integer.parseInt(uid);
            } catch (NumberFormatException e) {
                System.err.println("ID format error: " + e.getMessage());
                request.setAttribute("Message", "Invalid user ID format.");
                getServletContext().getRequestDispatcher("/errorPage.jsp").forward(request, response);
                return;
            }
        }

        // Obtains the upload file part in this multipart request
        Part filePart = request.getPart("photo");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("Message", "No file uploaded.");
            getServletContext().getRequestDispatcher("/errorPage.jsp").forward(request, response);
            return;
        }

        // prints out some information for debugging
        System.out.println("File Name: " + filePart.getName());
        System.out.println("File Size: " + filePart.getSize());
        System.out.println("File Content Type: " + filePart.getContentType());

        // obtains input stream of the upload file
        InputStream inputStream = filePart.getInputStream();

        // Sends the statement to the database server
        int row = fileUploadDao.uploadFile(id, inputStream);
        String message;
        if (row > 0) {
            message = "File uploaded successfully!";
        } else {
            message = "File upload failed.";
        }

        // sets the message in request scope
        request.setAttribute("Message", message);

        // forwards to the message page
        getServletContext().getRequestDispatcher("/message.jsp").forward(request, response);
    }
}
