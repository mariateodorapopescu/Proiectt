package Servlet;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

import bean.MyUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

public class LeaveDataServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        String username = currentUser.getUsername();
        
        // Obținem parametrii din request
        String statusParam = request.getParameter("status");
        String departmentParam = request.getParameter("department");
        
        System.out.println("Parameters - Status: " + statusParam + ", Department: " + departmentParam);
        
        // Valori implicite
        int status = 3; // 3 = Oricare
        int departmentId = 0; // 0 = Toate departamentele
        
        try {
            if (statusParam != null && !statusParam.isEmpty()) {
                status = Integer.parseInt(statusParam);
            }
            if (departmentParam != null && !departmentParam.isEmpty()) {
                departmentId = Integer.parseInt(departmentParam);
            }
        } catch (NumberFormatException e) {
            System.out.println("Error parsing parameters: " + e.getMessage());
        }
        
        System.out.println("Using filters - Status: " + status + ", Department: " + departmentId);
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                
                int userId = 0;
                int userDepartmentId = 0;
                int ierarhie = 0;
                
                // Obținem informațiile despre utilizator
                String userQuery = "SELECT u.id, u.id_dep, t.ierarhie " +
                                   "FROM useri u " +
                                   "JOIN tipuri t ON u.tip = t.tip " +
                                   "WHERE u.username = ?";
                
                try (PreparedStatement userStmt = conn.prepareStatement(userQuery)) {
                    userStmt.setString(1, username);
                    try (ResultSet userRs = userStmt.executeQuery()) {
                        if (userRs.next()) {
                            userId = userRs.getInt("id");
                            userDepartmentId = userRs.getInt("id_dep");
                            ierarhie = userRs.getInt("ierarhie");
                            System.out.println("User info - ID: " + userId + ", Department: " + userDepartmentId + ", Ierarhie: " + ierarhie);
                        } else {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                            return;
                        }
                    }
                }
                
                // Determinăm rolul utilizatorului
                boolean isDirector = (ierarhie < 3);
                boolean isSef = (ierarhie >= 4 && ierarhie <= 5);
                System.out.println("User roles - Director: " + isDirector + ", Sef: " + isSef);
                
                // Construim partea comună a query-ului
                StringBuilder queryBuilder = new StringBuilder();
                queryBuilder.append("SELECT c.id, c.id_ang, u.nume, u.prenume, d.nume_dep, ")
                           .append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, ")
                           .append("s.nume_status, u.culoare, tc.motiv AS tip_concediu, c.status ")
                           .append("FROM concedii c ")
                           .append("JOIN useri u ON c.id_ang = u.id ")
                           .append("JOIN departament d ON u.id_dep = d.id_dep ")
                           .append("JOIN tipuri t ON u.tip = t.tip ")
                           .append("JOIN statusuri s ON c.status = s.status ")
                           .append("JOIN tipcon tc ON c.tip = tc.tip ");
                
                // Adăugăm condițiile WHERE în funcție de rol și filtre
                boolean addedWhereClause = false;
                PreparedStatement leaveStmt;
                
                // 1. Filtrare după rol (director, șef, utilizator normal)
                if (!isDirector && !isSef) {
                    // Utilizator normal/începător - vede doar concediile proprii
                    queryBuilder.append("WHERE c.id_ang = ? ");
                    addedWhereClause = true;
                } else if (isSef) {
                    // Șef - vede concediile din departamentul său
                    queryBuilder.append("WHERE u.id_dep = ? ");
                    addedWhereClause = true;
                } else if (isDirector && departmentId > 0) {
                    // Director cu departament specificat
                    queryBuilder.append("WHERE u.id_dep = ? ");
                    addedWhereClause = true;
                }
                
                // 2. Filtrare după status (dacă este selectat un status specific)
                if (status != 3) {
                    if (addedWhereClause) {
                        queryBuilder.append("AND c.status = ? ");
                    } else {
                        queryBuilder.append("WHERE c.status = ? ");
                        addedWhereClause = true;
                    }
                }
                
                // Query-ul final
                String leaveQuery = queryBuilder.toString();
                System.out.println("Final query: " + leaveQuery);
                
                // Pregătim statement-ul cu parametrii necesari
                leaveStmt = conn.prepareStatement(leaveQuery);
                
                int paramIndex = 1;
                
                // Adăugăm parametrii în funcție de condițiile din WHERE
                if (!isDirector && !isSef) {
                    leaveStmt.setInt(paramIndex++, userId);
                } else if (isSef) {
                    leaveStmt.setInt(paramIndex++, userDepartmentId);
                } else if (isDirector && departmentId > 0) {
                    leaveStmt.setInt(paramIndex++, departmentId);
                }
                
                if (status != 3) {
                    leaveStmt.setInt(paramIndex++, status);
                }
                
                // Executăm query-ul și construim răspunsul JSON
                JSONArray eventsArray = new JSONArray();
                try (ResultSet rs = leaveStmt.executeQuery()) {
                    int count = 0;
                    while (rs.next()) {
                        count++;
                        JSONObject event = new JSONObject();
                        
                        String statusName = rs.getString("nume_status");
                        String title = rs.getString("nume") + " " + rs.getString("prenume") + " - " + rs.getString("tip_concediu");
                        String department = rs.getString("nume_dep");
                        String color = rs.getString("culoare");
                        int eventStatus = rs.getInt("status");
                        
                        // Adăugăm detalii suplimentare în titlu în funcție de rol
                        if ((isDirector || isSef) && rs.getInt("id_ang") != userId) {
                            title += " (" + department + ")";
                        }
                        
                        event.put("id", rs.getInt("id"));
                        event.put("title", title);
                        event.put("start", rs.getDate("start_c").toString());
                        
                        // Asigură-te că end_c nu este null
                        java.sql.Date endDate = rs.getDate("end_c");
                        if (endDate != null) {
                            event.put("end", endDate.toString());
                        } else {
                            event.put("end", rs.getDate("start_c").toString());
                        }
                        
                        event.put("description", rs.getString("motiv"));
                        event.put("location", rs.getString("locatie"));
                        event.put("status", statusName);
                        event.put("statusCode", eventStatus);
                        
                        // Personalizăm culoarea evenimentului în funcție de status
                        switch (eventStatus) {
                            case -2: // Dezaprobat director
                                event.put("textColor", "#FFFFFF");
                                event.put("backgroundColor", "#DC3545");
                                event.put("borderColor", "#DC3545");
                                break;
                            case -1: // Dezaprobat șef
                                event.put("textColor", "#FFFFFF");
                                event.put("backgroundColor", "#FD7E14");
                                event.put("borderColor", "#FD7E14");
                                break;
                            case 0: // Neaprobat
                                event.put("textColor", "#212529");
                                event.put("backgroundColor", "#FFC107");
                                event.put("borderColor", "#FFC107");
                                event.put("className", "tentative-event");
                                break;
                            case 1: // Aprobat șef
                                event.put("textColor", "#FFFFFF");
                                event.put("backgroundColor", "#0DCAF0");
                                event.put("borderColor", "#0DCAF0");
                                break;
                            case 2: // Aprobat director
                                event.put("textColor", "#FFFFFF");
                                event.put("backgroundColor", "#198754");
                                event.put("borderColor", "#198754");
                                break;
                            default:
                                // Culoare implicită (culoarea utilizatorului)
                                event.put("backgroundColor", color);
                                event.put("borderColor", color);
                                break;
                        }
                        
                        eventsArray.put(event);
                    }
                    System.out.println("Found " + count + " leave records");
                }
                
                out.print(eventsArray.toString());
            }
        } catch (Exception e) {
            System.out.println("Error in servlet: " + e.getMessage());
            e.printStackTrace();
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", e.getMessage());
            out.print(error.toString());
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}