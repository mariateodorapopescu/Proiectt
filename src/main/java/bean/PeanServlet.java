package bean;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PeanServlet", urlPatterns = {"/PeanServlet"})
public class PeanServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	PrintWriter out;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        out = response.getWriter();
        try {
            //getting parameter from jsp
            String jsonData = request.getParameter("para");
            
            Gson gson = new Gson();

            //converting it into bean
            Userr data = gson.fromJson(jsonData, Userr.class);

            //calling the getter method
            String name = data.getName();
            String address = data.getAddress();

            Userr user = new Userr();

            //setting values to object
            user.setName(name);
            user.setAddress(address);

            //converting
            String jsonObj = gson.toJson(user);
           
            out.print(jsonObj);
        } catch (JsonSyntaxException e) {
            out.println(e);
        }
    }

}
