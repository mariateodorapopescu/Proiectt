package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
//In your Java project

public class DataServlet extends HttpServlet {
 
 @Override
 protected void doGet(HttpServletRequest request, HttpServletResponse response) 
         throws ServletException, IOException {
     response.setContentType("application/json");
     response.setCharacterEncoding("UTF-8");
     
     // Enable CORS for cross-origin requests
     response.setHeader("Access-Control-Allow-Origin", "*");
     response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
     response.setHeader("Access-Control-Allow-Headers", "Content-Type");
     
     String jsonResponse = "{\"message\": \"Hello from Java!\", \"status\": \"success\"}";
     response.getWriter().write(jsonResponse);
 }
 
 @Override
 protected void doPost(HttpServletRequest request, HttpServletResponse response) 
         throws ServletException, IOException {
     // Read JSON data from Python
     StringBuilder buffer = new StringBuilder();
     String line;
     BufferedReader reader = request.getReader();
     while ((line = reader.readLine()) != null) {
         buffer.append(line);
     }
     String jsonData = buffer.toString();
     
     // Process the data (you can use libraries like Jackson or Gson for JSON parsing)
     System.out.println("Received from Python: " + jsonData);
     
     response.setContentType("application/json");
     response.setHeader("Access-Control-Allow-Origin", "*");
     response.getWriter().write("{\"status\": \"received\", \"echo\": \"" + jsonData + "\"}");
 }
}
