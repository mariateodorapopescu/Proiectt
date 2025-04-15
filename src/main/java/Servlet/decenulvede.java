package Servlet;
import bean.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

/**
 * Server ce accepta atat get cat si post si creaza un json care pune ce concedii sunt intr-o zi, in fiecare zi a unui an
 */
public class decenulvede extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONArray events = new JSONArray();
        try {
            int departmentId = getUserDepartment(request);
            if (departmentId != -1) {
                // Obține parametrul status din cerere, valoarea default este 2 (aprobat director)
                String statusParam = request.getParameter("status");
                int status = 2; // valoare default
                
                // Dacă statusParam nu este null și este un număr valid
                if (statusParam != null && !statusParam.isEmpty()) {
                    try {
                        status = Integer.parseInt(statusParam);
                    } catch (NumberFormatException e) {
                        // Ignoră și folosește valoarea default
                    }
                }
                
                loadDepartmentLeaves(departmentId, events, status);
            } 
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Internal Server Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONArray events = new JSONArray();
        try {
            int departmentId = getUserDepartment(request);
            if (departmentId != -1) {
                // Obține parametrul status din cerere, valoarea default este 2 (aprobat director)
                String statusParam = request.getParameter("status");
                int status = 2; // valoare default
                
                // Dacă statusParam nu este null și este un număr valid
                if (statusParam != null && !statusParam.isEmpty()) {
                    try {
                        status = Integer.parseInt(statusParam);
                    } catch (NumberFormatException e) {
                        // Ignoră și folosește valoarea default
                    }
                }
                
                loadDepartmentLeaves(departmentId, events, status);
            }
            PrintWriter out = response.getWriter();
            out.print(events.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Internal Server Error: " + e.getMessage());
        }
    }
    
    private int getUserDepartment(HttpServletRequest request) throws ClassNotFoundException, SQLException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            MyUser currentUser = (MyUser) session.getAttribute("currentUser");
            if (currentUser != null) {
            	// cum numele de utilizator este unic...
            	// aceeasi pasi ca mai sus, sunt urmati si aici
                String username = currentUser.getUsername();
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement preparedStatement = connection.prepareStatement("SELECT id_dep FROM useri WHERE username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                        return rs.getInt("id_dep");
                    }
                }
            }
        }
        return -1;
    }

    private void loadDepartmentLeaves(int departmentId, JSONArray events, int status) throws ClassNotFoundException, SQLException {
    	// initializarea driverului pentru Jdbc
    	// crearea conexiunii pentru baza de date
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Creează interogarea SQL în funcție de status
        String sql;
        if (status == 3) {
            // Încarcă toate concediile, indiferent de status
            sql = "SELECT culoare, accent, nume, prenume, start_c, end_c FROM concedii JOIN useri ON concedii.id_ang = useri.id JOIN teme ON useri.id = teme.id_usr WHERE useri.id_dep = ?";
        } else {
            // Încarcă doar concediile cu status-ul specificat
            sql = "SELECT culoare, accent, nume, prenume, start_c, end_c FROM concedii JOIN useri ON concedii.id_ang = useri.id JOIN teme ON useri.id = teme.id_usr WHERE useri.id_dep = ? AND concedii.status = ?";
        }
        
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            // pregatirea interogarii
            PreparedStatement statement = connection.prepareStatement(sql)) {
            
            // setare variabile in interogare
        	statement.setInt(1, departmentId);
            
            // Adaugă al doilea parametru doar dacă selectăm un status specific
            if (status != 3) {
                statement.setInt(2, status);
            }
            
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
            	// de fiecare data cand a gasit ceva, il pune in json cu nume, prenume, data inceput/final. locatie, motiv, tip, completand obiectul de tip concediu
                JSONObject event = new JSONObject();
                event.put("title", rs.getString("nume") + " " + rs.getString("prenume"));
                event.put("start", rs.getDate("start_c").toString());
                event.put("end", rs.getDate("end_c").toString());
                event.put("color", rs.getString("culoare"));
                event.put("textColor", "white");
                events.put(event);
            }
        }
    }
}