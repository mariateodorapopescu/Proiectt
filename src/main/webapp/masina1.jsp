<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>

<%
    try {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Citire JSON din request
        StringBuilder jsonBody = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBody.append(line).append("\n");
            }
        }

        String jsonStr = jsonBody.toString().trim();
        System.out.println("JSON String primit: " + jsonStr);  // Debug

        // Verificare JSON gol
        if (jsonStr.isEmpty()) {
            throw new Exception("Empty request body");
        }

        // Parsare JSON
        JSONObject inputJson = new JSONObject(jsonStr);
        System.out.println("JSON Object parsed: " + inputJson.toString());  // Debug

        // Verificare sesiune
        HttpSession sesi = request.getSession(false);
        if (sesi == null) {
            throw new Exception("Nu există sesiune activă");
        }

        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser == null) {
            throw new Exception("Utilizator neconectat");
        }

        // Obținere informații utilizator
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");

        try {
            PreparedStatement userStmt = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                    "dp.denumire_completa AS denumire FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                    "WHERE u.username = ?");
            userStmt.setString(1, username);
            ResultSet userRs = userStmt.executeQuery();

            if (!userRs.next()) {
                throw new Exception("Utilizator negăsit");
            }

            int userType = userRs.getInt("tip");
            int userId = userRs.getInt("id");
            int userDep = userRs.getInt("id_dep");
            String prenume = userRs .getString("prenume");
            String functie = userRs .getString("functie");
            int ierarhie = userRs .getInt("ierarhie");
            // Funcție helper pentru a determina rolul utilizatorului
            boolean isDirector = (ierarhie < 3) ;
            boolean isSef = (ierarhie >= 4 && ierarhie <=5);
            boolean isIncepator = (ierarhie >= 10);
            boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
            boolean isAdmin = (functie.compareTo("Administrator") == 0);

            if (isAdmin) {
                throw new Exception("Acces restricționat pentru administratori");
            }

            // Parsare parametri din JSON
            int id = inputJson.optInt("id", userId);
            int status = inputJson.optInt("status", 3);
            int tip = inputJson.optInt("tip", -1);
            int dep = inputJson.optInt("dep", userDep);
            int pag = inputJson.optInt("pag", 3);
            boolean an = "1".equals(inputJson.optString("an", "0"));
            String start = inputJson.optString("start", "");
            String end = inputJson.optString("end", "");

            // Determinare perioadă
            int perioada = (!an && !start.isEmpty() && !end.isEmpty()) ? 1 : 0;

            // Construire query
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT c.acc_res, c.added, c.modified, c.id AS nr_crt, ");
            sql.append("d.nume_dep AS departament, u.nume, u.prenume, ");
            sql.append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, ");
            sql.append("c.locatie, s.nume_status AS status, ct.motiv as tipcon ");
            sql.append("FROM useri u ");
            sql.append("JOIN tipuri t ON u.tip = t.tip ");
            sql.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("JOIN concedii c ON c.id_ang = u.id ");
            sql.append("JOIN statusuri s ON c.status = s.status ");
            sql.append("JOIN tipcon ct ON c.tip = ct.tip ");

            List<Object> params = new ArrayList<>();

            // Adăugare condiții WHERE
            if (pag == 3 || pag == 4 || pag == 5) {
                sql.append(" WHERE c.id_ang = ? AND u.username <> 'test'");
                params.add(id);
            } else if (pag == 6 || pag == 7) {
                sql.append(" WHERE u.id_dep = ? AND u.tip <> 4");
                params.add(dep);
                if (pag == 6 || (pag == 7 && dep == userDep)) {
                    sql.append(" AND c.id_ang <> ?");
                    params.add(userId);
                }
            } else if (pag == 8) {
                sql.append(" WHERE u.id <> ?");
                params.add(userId);
            }

            // Adăugare condiții comune
            if (perioada == 0) {
                sql.append(" AND YEAR(c.start_c) = YEAR(CURDATE())");
            }
            if (tip != -1) {
                sql.append(" AND c.tip = ?");
                params.add(tip);
            }
            if (status != 3) {
                sql.append(" AND c.status = ?");
                params.add(status);
            }
            if (perioada == 1) {
                sql.append(" AND c.start_c BETWEEN ? AND ? AND c.end_c <= ?");
                params.add(start);
                params.add(end);
                params.add(end);
            }

            // Executare query
            PreparedStatement stmt = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            System.out.println("Executing query: " + sql.toString());
            System.out.println("With parameters: " + params);

            ResultSet rs = stmt.executeQuery();
            JSONArray data = new JSONArray();
            int nr = 1;

            while (rs.next()) {
                JSONObject row = new JSONObject();
                row.put("NrCrt", nr++);
                row.put("Nume", rs.getString("nume"));
                row.put("Prenume", rs.getString("prenume"));
                row.put("Functie", rs.getString("functie"));
                row.put("Departament", rs.getString("departament"));
                row.put("Inceput", rs.getString("start_c"));
                row.put("Final", rs.getString("end_c"));
                row.put("Motiv", rs.getString("motiv"));
                row.put("Locatie", rs.getString("locatie") != null ? rs.getString("locatie") : "N/A");
                row.put("Tip", rs.getString("tipcon"));
                row.put("Adaugat", rs.getString("added") != null ? rs.getString("added") : "N/A");
                row.put("Modificat", rs.getString("modified") != null ? rs.getString("modified") : "N/A");
                row.put("Vazut", rs.getString("acc_res") != null ? rs.getString("acc_res") : "N/A");
                row.put("Status", rs.getString("status"));
                row.put("id", rs.getString("nr_crt"));
                data.put(row);
            }

         // După ce obținem toate datele necesare și înainte de a construi răspunsul JSON, adăugăm:

         // Determinare titlu în funcție de pagină și perioadă
         String pageTitle = "";
         switch (pag) {
             case 3: 
                 pageTitle = "Vizualizare concedii personale";
                 break;
             case 4: 
                 pageTitle = "Vizualizare concedii ale unui angajat";
                 break;
             case 5: 
                 pageTitle = "Vizualizare concedii ale unui coleg din departament";
                 break;
             case 6: 
                 pageTitle = "Vizualizare concedii din departamentul meu";
                 break;
             case 7: 
                 pageTitle = "Vizualizare concedii dintr-un departament";
                 break;
             case 8: 
                 pageTitle = "Vizualizare concedii din toată instituția";
                 break;
             default: 
                 pageTitle = "Vizualizare concedii";
         }

         // Adăugăm perioada la titlu
         if (perioada == 0) {
             pageTitle += " pe an";
         } else {
             pageTitle += " pe perioada " + start + " - " + end;
         }

         // Obținem data curentă formatată
         PreparedStatement dateStmt = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today");
         ResultSet dateRs = dateStmt.executeQuery();
         String today = dateRs.next() ? dateRs.getString("today") : "";
         dateRs.close();
         dateStmt.close();

         // Actualizăm construirea răspunsului JSON
         JSONObject result = new JSONObject();
         result.put("success", true);
         result.put("data", data);
         result.put("count", data.length());
         result.put("header", pageTitle);
         result.put("today", today);

         out.print(result.toString());

        } finally {
            if (connection != null) {
                connection.close();
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        JSONObject error = new JSONObject();
        error.put("success", false);
        error.put("error", e.getMessage());
        error.put("stack", e.toString());
        out.print(error.toString());
    }
%>