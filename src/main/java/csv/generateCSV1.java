package csv;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import org.json.JSONArray;
import org.json.JSONObject;

public class generateCSV1 extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("generateCSV1 Servlet invoked");
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment;filename=table_data.csv");

        try (PrintWriter out = response.getWriter()) {
            // Read JSON data from request body
            StringBuilder jsonInput = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    jsonInput.append(line);
                }
            }
            System.out.println("Received JSON: " + jsonInput);

            // Parse JSON and generate CSV
            JSONArray jsonArray = new JSONArray(jsonInput.toString());
            if (!jsonArray.isEmpty()) {
                JSONObject firstObject = jsonArray.getJSONObject(0);
                out.println(String.join(",", firstObject.keySet()));
            }
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = jsonArray.getJSONObject(i);
                out.println(jsonObject.keySet().stream()
                        .map(key -> jsonObject.optString(key, ""))
                        .reduce((a, b) -> a + "," + b).orElse(""));
            }
            System.out.println("CSV generated successfully");
            out.flush();
        } catch (Exception e) {
            System.err.println("Error generating CSV: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error generating CSV: " + e.getMessage());
        }
    }
}


