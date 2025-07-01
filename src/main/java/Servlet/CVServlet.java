package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import bean.MyUser;

public class CVServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    /**
     * Metodă helper pentru a obține userId din sesiune folosind MyUser și username
     */
    private int getUserIdFromSession(HttpSession session, Connection conn) throws SQLException {
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            throw new SQLException("Utilizator neautentificat");
            String username = currentUser.getUsername();
            String sql = "SELECT id FROM useri WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("id");
                    } else {
                        throw new SQLException("Utilizator negăsit în baza de date");
                    }
                }
            }
        }
            /**
     * Generează răspuns HTML direct - EVITĂ complet JSP-urile problematice
     */
    private void generateCVResponse(HttpServletResponse response, 
                                   ResultSet userRs, ResultSet cvRs, ResultSet experienceRs, 
                                   ResultSet educationRs, ResultSet languagesRs, ResultSet projectsRs,
                                   boolean isDirector, boolean isHR, boolean isAdmin, 
                                   int targetUserId, int currentUserId) throws IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html lang='ro'>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
            out.println("<title>Vizualizare CV</title>");
            out.println("<link rel='stylesheet' href='css/style.css'>");
            generateCSS(out);
            out.println("</head>");
            out.println("<body class='bg' onload='getTheme()'>");
            out.println("<div class='cv-container'>");
            
            try {
                // Header cu informații personale
                if (userRs != null && userRs.next()) {
                    out.println("<div class='cv-header'>");
                    out.println("<h1>" + safe(userRs.getString("nume")) + " " + safe(userRs.getString("prenume")) + "</h1>");
                    out.println("<div class='info-grid'>");
                    out.println("<div class='info-item'><span class='info-label'>Poziție:</span> " + safe(userRs.getString("denumire")) + "</div>");
                    out.println("<div class='info-item'><span class='info-label'>Departament:</span> " + safe(userRs.getString("nume_dep")) + "</div>");
                    out.println("<div class='info-item'><span class='info-label'>Email:</span> " + safe(userRs.getString("email")) + "</div>");
                    out.println("<div class='info-item'><span class='info-label'>Telefon:</span> " + safe(userRs.getString("telefon")) + "</div>");
                    out.println("</div>");
                    out.println("</div>");
                }
                
                // Secțiunea CV (calități și interese)
                if (cvRs != null && cvRs.next()) {
                    out.println("<div class='cv-section'>");
                    out.println("<h3>📋 Calități Personale</h3>");
                    out.println("<p>" + safe(cvRs.getString("calitati"), "Nu sunt specificate calități.") + "</p>");
                    out.println("</div>");
                    
                    out.println("<div class='cv-section'>");
                    out.println("<h3>🎯 Interese</h3>");
                    out.println("<p>" + safe(cvRs.getString("interese"), "Nu sunt specificate interese.") + "</p>");
                    out.println("</div>");
                }
                
                // Secțiunea Experiență
                out.println("<div class='cv-section'>");
                out.println("<h3>💼 Experiență Profesională</h3>");
                boolean hasExperience = false;
                if (experienceRs != null) {
                    while (experienceRs.next()) {
                        hasExperience = true;
                        out.println("<div class='experience-item'>");
                        out.println("<h4>" + safe(experienceRs.getString("den_job"), "Poziție nespecificată") + "</h4>");
                        out.println("<p><strong>Instituție:</strong> " + safe(experienceRs.getString("instit")) + "</p>");
                        out.println("<p><strong>Domeniu:</strong> " + safe(experienceRs.getString("domeniu")) + "</p>");
                        
                        if (experienceRs.getString("subdomeniu") != null) {
                            out.println("<p><strong>Subdomeniu:</strong> " + safe(experienceRs.getString("subdomeniu")) + "</p>");
                        }
                        if (experienceRs.getString("tip_denumire") != null) {
                            out.println("<p><strong>Tip poziție:</strong> " + safe(experienceRs.getString("tip_denumire")) + "</p>");
                        }
                        if (experienceRs.getString("nume_dep") != null) {
                            out.println("<p><strong>Departament:</strong> " + safe(experienceRs.getString("nume_dep")) + "</p>");
                        }
                        
                        String startDate = experienceRs.getDate("start") != null ? experienceRs.getDate("start").toString() : "Data necunoscută";
                        String endDate = experienceRs.getDate("end") != null ? experienceRs.getDate("end").toString() : "Prezent";
                        out.println("<p class='date-range'>" + startDate + " - " + endDate + "</p>");
                        
                        if (experienceRs.getString("descriere") != null && !experienceRs.getString("descriere").trim().isEmpty()) {
                            out.println("<p><strong>Descriere:</strong> " + safe(experienceRs.getString("descriere")) + "</p>");
                        }
                        out.println("</div>");
                    }
                }
                if (!hasExperience) {
                    out.println("<p>Nu este specificată experiență profesională.</p>");
                }
                out.println("</div>");
                
                // Secțiunea Educație
                out.println("<div class='cv-section'>");
                out.println("<h3>🎓 Educație</h3>");
                boolean hasEducation = false;
                if (educationRs != null) {
                    while (educationRs.next()) {
                        hasEducation = true;
                        out.println("<div class='education-item'>");
                        out.println("<h4>" + safe(educationRs.getString("facultate"), "Facultate nespecificată") + "</h4>");
                        out.println("<p><strong>Universitate:</strong> " + safe(educationRs.getString("universitate")) + "</p>");
                        out.println("<p><strong>Ciclu:</strong> " + safe(educationRs.getString("ciclu_denumire")) + "</p>");
                        
                        String startDate = educationRs.getDate("start") != null ? educationRs.getDate("start").toString() : "Data necunoscută";
                        String endDate = educationRs.getDate("end") != null ? educationRs.getDate("end").toString() : "În curs";
                        out.println("<p class='date-range'>" + startDate + " - " + endDate + "</p>");
                        out.println("</div>");
                    }
                }
                if (!hasEducation) {
                    out.println("<p>Nu este specificată educație.</p>");
                }
                out.println("</div>");
                
                // Secțiunea Limbi Străine
                out.println("<div class='cv-section'>");
                out.println("<h3>🌍 Limbi Străine</h3>");
                out.println("<div class='languages-container'>");
                boolean hasLanguages = false;
                if (languagesRs != null) {
                    while (languagesRs.next()) {
                        hasLanguages = true;
                        out.println("<span class='language-tag'>" + 
                                  safe(languagesRs.getString("limba")) + " - " + 
                                  safe(languagesRs.getString("nivel_denumire")) + "</span>");
                    }
                }
                if (!hasLanguages) {
                    out.println("<p>Nu sunt specificate limbi străine.</p>");
                }
                out.println("</div>");
                out.println("</div>");
                
                // Secțiunea Proiecte (dacă există)
                if (projectsRs != null) {
                    out.println("<div class='cv-section'>");
                    out.println("<h3>🚀 Proiecte</h3>");
                    boolean hasProjects = false;
                    while (projectsRs.next()) {
                        hasProjects = true;
                        out.println("<div class='experience-item'>");
                        out.println("<h4>" + safe(projectsRs.getString("nume"), "Proiect nespecificat") + "</h4>");
                        out.println("<p>" + safe(projectsRs.getString("descriere"), "Fără descriere") + "</p>");
                        
                        String startDate = projectsRs.getDate("start") != null ? projectsRs.getDate("start").toString() : "Data necunoscută";
                        String endDate = projectsRs.getDate("end") != null ? projectsRs.getDate("end").toString() : "În curs";
                        out.println("<p class='date-range'>" + startDate + " - " + endDate + "</p>");
                        out.println("</div>");
                    }
                    if (!hasProjects) {
                        out.println("<p>Nu sunt specificate proiecte.</p>");
                    }
                    out.println("</div>");
                }
                
                // Butoane de acțiune
                out.println("<div class='cv-actions'>");
                if (currentUserId == targetUserId) {
                    out.println("<a href='CVServlet?action=edit' class='btn'>✏️ Editează CV</a>");
                    out.println("<a href='CVServlet?action=create' class='btn'>📝 Creare CV</a>");
                }
                if (isDirector || isHR || currentUserId == targetUserId) {
                    out.println("<a href='CVGeneratorServlet?action=export&id=" + targetUserId + "' class='btn'>📥 Exportă PDF</a>");
                }
                out.println("<a href='cvmanagement.jsp' class='btn btn-secondary'>🏠 Management CV</a>");
                out.println("<a href='homedir.jsp' class='btn btn-secondary'>🔙 Înapoi</a>");
                out.println("</div>");
                
            } catch (SQLException e) {
                out.println("<div style='color: red; text-align: center; padding: 20px;'>");
                out.println("<h3>Eroare la încărcarea CV-ului</h3>");
                out.println("<p>A apărut o eroare: " + safe(e.getMessage()) + "</p>");
                out.println("<a href='cvmanagement.jsp' class='btn'>Înapoi la Management CV</a>");
                out.println("</div>");
                e.printStackTrace();
            }
            
            out.println("</div>");
            out.println("<script src='js/core2.js'></script>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    /**
     * Generează CSS-ul pentru pagină
     */
    private void generateCSS(PrintWriter out) {
        out.println("<style>");
        out.println(".cv-container { max-width: 900px; margin: 0 auto; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }");
        out.println(".cv-header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #3498db; }");
        out.println(".cv-header h1 { color: #2c3e50; margin-bottom: 10px; }");
        out.println(".cv-section { margin-bottom: 25px; }");
        out.println(".cv-section h3 { color: #2c3e50; border-bottom: 1px solid #ecf0f1; padding-bottom: 10px; margin-bottom: 15px; font-size: 1.3em; }");
        out.println(".experience-item, .education-item { margin-bottom: 15px; padding: 15px; background: #f8f9fa; border-left: 4px solid #3498db; border-radius: 5px; }");
        out.println(".experience-item h4, .education-item h4 { color: #2c3e50; margin: 0 0 10px 0; }");
        out.println(".date-range { font-style: italic; color: #7f8c8d; font-size: 0.9em; }");
        out.println(".languages-container { display: flex; flex-wrap: wrap; gap: 10px; }");
        out.println(".language-tag { background: #3498db; color: white; padding: 8px 15px; border-radius: 20px; font-size: 0.9em; display: inline-block; }");
        out.println(".cv-actions { margin-top: 30px; text-align: center; border-top: 1px solid #ecf0f1; padding-top: 20px; }");
        out.println(".btn { display: inline-block; padding: 10px 20px; margin: 0 5px; border-radius: 5px; text-decoration: none; color: white; background: #3498db; transition: background 0.3s; }");
        out.println(".btn:hover { background: #2980b9; }");
        out.println(".btn-secondary { background: #95a5a6; }");
        out.println(".btn-secondary:hover { background: #7f8c8d; }");
        out.println(".info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 10px; margin-bottom: 20px; }");
        out.println(".info-item { background: #ecf0f1; padding: 10px; border-radius: 5px; }");
        out.println(".info-label { font-weight: bold; color: #2c3e50; }");
        out.println("@media (max-width: 768px) { .cv-container { margin: 10px; padding: 15px; } .info-grid { grid-template-columns: 1fr; } }");
        out.println("</style>");
    }
    
    /**
     * Metodă helper pentru a face safe string-urile (evită null și XSS)
     */
    private String safe(String str) {
        return safe(str, "N/A");
    }
    
    private String safe(String str, String defaultValue) {
        if (str == null || str.trim().isEmpty()) {
            return defaultValue;
        }
        // Escape HTML pentru securitate
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }
    private Map<String, String> extractUserData(ResultSet rs) throws SQLException {
        Map<String, String> data = new HashMap<>();
        if (rs != null && rs.next()) {
            data.put("nume", rs.getString("nume"));
            data.put("prenume", rs.getString("prenume"));
            data.put("email", rs.getString("email"));
            data.put("telefon", rs.getString("telefon"));
            data.put("nume_dep", rs.getString("nume_dep"));
            data.put("denumire", rs.getString("denumire"));
        }
        return data;
    }
    
    private Map<String, String> extractCvData(ResultSet rs) throws SQLException {
        Map<String, String> data = new HashMap<>();
        if (rs != null && rs.next()) {
            data.put("calitati", rs.getString("calitati"));
            data.put("interese", rs.getString("interese"));
        }
        return data;
    }
    
    private List<Map<String, String>> extractExperienceData(ResultSet rs) throws SQLException {
        List<Map<String, String>> list = new ArrayList<>();
        if (rs != null) {
            while (rs.next()) {
                Map<String, String> exp = new HashMap<>();
                exp.put("den_job", rs.getString("den_job"));
                exp.put("instit", rs.getString("instit"));
                exp.put("domeniu", rs.getString("domeniu"));
                exp.put("subdomeniu", rs.getString("subdomeniu"));
                exp.put("tip_denumire", rs.getString("tip_denumire"));
                exp.put("nume_dep", rs.getString("nume_dep"));
                exp.put("start", rs.getDate("start") != null ? rs.getDate("start").toString() : null);
                exp.put("end", rs.getDate("end") != null ? rs.getDate("end").toString() : null);
                exp.put("descriere", rs.getString("descriere"));
                list.add(exp);
            }
        }
        return list;
    }
    
    private List<Map<String, String>> extractEducationData(ResultSet rs) throws SQLException {
        List<Map<String, String>> list = new ArrayList<>();
        if (rs != null) {
            while (rs.next()) {
                Map<String, String> edu = new HashMap<>();
                edu.put("facultate", rs.getString("facultate"));
                edu.put("universitate", rs.getString("universitate"));
                edu.put("ciclu_denumire", rs.getString("ciclu_denumire"));
                edu.put("start", rs.getDate("start") != null ? rs.getDate("start").toString() : null);
                edu.put("end", rs.getDate("end") != null ? rs.getDate("end").toString() : null);
                list.add(edu);
            }
        }
        return list;
    }
    
    private List<Map<String, String>> extractLanguagesData(ResultSet rs) throws SQLException {
        List<Map<String, String>> list = new ArrayList<>();
        if (rs != null) {
            while (rs.next()) {
                Map<String, String> lang = new HashMap<>();
                lang.put("limba", rs.getString("limba"));
                lang.put("nivel_denumire", rs.getString("nivel_denumire"));
                list.add(lang);
            }
        }
        return list;
    }
    
    private List<Map<String, String>> extractProjectsData(ResultSet rs) throws SQLException {
        List<Map<String, String>> list = new ArrayList<>();
        if (rs != null) {
            while (rs.next()) {
                Map<String, String> proj = new HashMap<>();
                proj.put("nume", rs.getString("nume"));
                proj.put("descriere", rs.getString("descriere"));
                proj.put("start", rs.getDate("start") != null ? rs.getDate("start").toString() : null);
                proj.put("end", rs.getDate("end") != null ? rs.getDate("end").toString() : null);
                list.add(proj);
            }
        }
        return list;
    }
        
     
    
    /**
     * Metodă helper pentru a obține datele complete ale utilizatorului
     */
    private ResultSet getCurrentUserData(HttpSession session, Connection conn) throws SQLException {
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            throw new SQLException("Utilizator neautentificat");
        }
        
        String username = currentUser.getUsername();
        String sql = "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie, " +
                    "dp.denumire_completa AS denumire FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                    "WHERE u.username = ?";
        
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        return ps.executeQuery();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "view";
        
        switch(action) {
            case "view":
                viewCV(request, response);
                break;
            case "edit":
                editCV(request, response);
                break;
            case "create":
                createCV(request, response);
                break;
            default:
                viewCV(request, response);
        }
    }
    
    private void createCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect către viewcv.jsp (fără tag libraries problematice)
        response.sendRedirect("viewcv.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if ("save".equals(action)) {
            saveCV(request, response);
        } else if ("addExperience".equals(action)) {
            addExperience(request, response);
        } else if ("addEducation".equals(action)) {
            addEducation(request, response);
        } else if ("addLanguage".equals(action)) {
            addLanguage(request, response);
        } else if ("addProject".equals(action)) {
            addProject(request, response);
        }
    }
    
    private void viewCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            
            // Obține datele utilizatorului curent
            ResultSet currentUserRs = getCurrentUserData(session, conn);
            int currentUserId = 0;
            int currentUserDep = 0;
            int currentUserIerarhie = 0;
            String currentUserFunctie = "";
            
            if (currentUserRs.next()) {
                currentUserId = currentUserRs.getInt("id");
                currentUserDep = currentUserRs.getInt("id_dep");
                currentUserIerarhie = currentUserRs.getInt("ierarhie");
                currentUserFunctie = currentUserRs.getString("functie");
            }
            
            // Determină privilegiile
            boolean isDirector = (currentUserIerarhie < 3);
            boolean isHR = (currentUserDep == 1);
            boolean isAdmin = (currentUserFunctie != null && currentUserFunctie.compareTo("Administrator") == 0);
            
            int targetUserId;
            
            // Dacă este HR/Director și vede CV-ul unui alt utilizator
            if (request.getParameter("id") != null && (isHR || isDirector)) {
                try {
                    targetUserId = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    targetUserId = currentUserId;
                }
            } else {
                targetUserId = currentUserId;
            }
            
            // Date personale pentru targetUser
            String sql = "SELECT u.*, d.nume_dep, t.denumire " +
                         "FROM useri u " +
                         "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN tipuri t ON u.tip = t.tip " +
                         "WHERE u.id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet userRs = ps.executeQuery();
            
            // CV data
            sql = "SELECT * FROM cv WHERE id_ang = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet cvRs = ps.executeQuery();
            
            // Experiență
            sql = "SELECT e.*, t.denumire as tip_denumire, d.nume_dep " +
                  "FROM experienta e " +
                  "LEFT JOIN tipuri t ON e.tip = t.tip " +
                  "LEFT JOIN departament d ON e.id_dep = d.id_dep " +
                  "WHERE e.id_ang = ? ORDER BY e.start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet experienceRs = ps.executeQuery();
            
            // Educație
            sql = "SELECT s.*, c.semnificatie as ciclu_denumire " +
                  "FROM studii s " +
                  "LEFT JOIN cicluri c ON s.ciclu = c.id " +
                  "WHERE s.id_ang = ? ORDER BY s.start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet educationRs = ps.executeQuery();
            
            // Limbi străine
            sql = "SELECT la.*, l.limba, n.semnificatie as nivel_denumire " +
                  "FROM limbi_ang la " +
                  "JOIN limbi l ON la.id_limba = l.id " +
                  "JOIN nivel n ON la.nivel = n.id " +
                  "WHERE la.id_ang = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet languagesRs = ps.executeQuery();
            
            // Proiecte - COMENTAT pentru că nu există id_ang în proiecte2
            /*
            sql = "SELECT * FROM proiecte2 WHERE id_ang = ? ORDER BY start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetUserId);
            ResultSet projectsRs = ps.executeQuery();
            */
            
            // Pentru moment, setăm null pentru proiecte
            ResultSet projectsRs = null;
            
            // Generează HTML direct - BYPASS complet orice problemă cu JSP
            generateCVResponse(response, userRs, cvRs, experienceRs, educationRs, 
                             languagesRs, projectsRs, isDirector, isHR, isAdmin, 
                             targetUserId, currentUserId);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void editCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect către viewcv.jsp (fără tag libraries problematice)
        response.sendRedirect("viewcv.jsp");
    }
    
    private void saveCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = getUserIdFromSession(session, conn);
            
            String calitati = request.getParameter("calitati");
            String interese = request.getParameter("interese");
            
            // Verifică dacă există deja un CV
            String checkSql = "SELECT COUNT(*) FROM cv WHERE id_ang = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, userId);
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            
            if (checkRs.getInt(1) > 0) {
                // Update
                String sql = "UPDATE cv SET calitati = ?, interese = ? WHERE id_ang = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, calitati);
                ps.setString(2, interese);
                ps.setInt(3, userId);
                ps.executeUpdate();
            } else {
                // Insert - Găsește primul ID disponibil
                String maxIdSql = "SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM cv";
                PreparedStatement maxIdPs = conn.prepareStatement(maxIdSql);
                ResultSet maxIdRs = maxIdPs.executeQuery();
                maxIdRs.next();
                int nextId = maxIdRs.getInt("next_id");
                
                String sql = "INSERT INTO cv (id, id_ang, calitati, interese) VALUES (?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, nextId);
                ps.setInt(2, userId);
                ps.setString(3, calitati);
                ps.setString(4, interese);
                ps.executeUpdate();
            }
            
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addExperience(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = getUserIdFromSession(session, conn);
            
            String den_job = request.getParameter("den_job");
            String instit = request.getParameter("instit");
            int tip = Integer.parseInt(request.getParameter("tip"));
            int id_dep = Integer.parseInt(request.getParameter("id_dep"));
            String domeniu = request.getParameter("domeniu");
            String subdomeniu = request.getParameter("subdomeniu");
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            String descriere = request.getParameter("descriere");
            
            // Găsește primul ID disponibil
            String maxIdSql = "SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM experienta";
            PreparedStatement maxIdPs = conn.prepareStatement(maxIdSql);
            ResultSet maxIdRs = maxIdPs.executeQuery();
            maxIdRs.next();
            int nextId = maxIdRs.getInt("next_id");
            
            String sql = "INSERT INTO experienta (id, den_job, instit, tip, id_dep, domeniu, subdomeniu, start, end, descriere, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, nextId);
            ps.setString(2, den_job);
            ps.setString(3, instit);
            ps.setInt(4, tip);
            ps.setInt(5, id_dep);
            ps.setString(6, domeniu);
            ps.setString(7, subdomeniu);
            ps.setString(8, start);
            ps.setString(9, end);
            ps.setString(10, descriere);
            ps.setInt(11, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addEducation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = getUserIdFromSession(session, conn);
            
            String facultate = request.getParameter("facultate");
            String universitate = request.getParameter("universitate");
            int ciclu = Integer.parseInt(request.getParameter("ciclu"));
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            
            // Găsește primul ID disponibil
            String maxIdSql = "SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM studii";
            PreparedStatement maxIdPs = conn.prepareStatement(maxIdSql);
            ResultSet maxIdRs = maxIdPs.executeQuery();
            maxIdRs.next();
            int nextId = maxIdRs.getInt("next_id");
            
            String sql = "INSERT INTO studii (id, facultate, universitate, ciclu, start, end, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, nextId);
            ps.setString(2, facultate);
            ps.setString(3, universitate);
            ps.setInt(4, ciclu);
            ps.setString(5, start);
            ps.setString(6, end);
            ps.setInt(7, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addLanguage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = getUserIdFromSession(session, conn);
            
            int id_limba = Integer.parseInt(request.getParameter("id_limba"));
            int nivel = Integer.parseInt(request.getParameter("nivel"));
            
            // Găsește primul ID disponibil
            String maxIdSql = "SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM limbi_ang";
            PreparedStatement maxIdPs = conn.prepareStatement(maxIdSql);
            ResultSet maxIdRs = maxIdPs.executeQuery();
            maxIdRs.next();
            int nextId = maxIdRs.getInt("next_id");
            
            String sql = "INSERT INTO limbi_ang (id, id_limba, nivel, id_ang) VALUES (?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, nextId);
            ps.setInt(2, id_limba);
            ps.setInt(3, nivel);
            ps.setInt(4, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addProject(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = getUserIdFromSession(session, conn);
            
            String nume = request.getParameter("nume");
            String descriere = request.getParameter("descriere");
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            
            // PROBLEMA: proiecte2 nu are coloana id_ang
            // SOLUȚIE TEMPORARĂ: Stochează proiectele fără legătura la user
            // Sau implementează o soluție alternativă
            
            // Opțiunea 1: Comentează această funcționalitate
            /*
            String sql = "INSERT INTO proiecte2 (nume, descriere, start, end, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, nume);
            ps.setString(2, descriere);
            ps.setString(3, start);
            ps.setString(4, end);
            ps.setInt(5, userId);
            
            ps.executeUpdate();
            */
            
            // Opțiunea 2: Adaugă fără id_ang (toate proiectele vor fi globale)
            // Găsește primul ID disponibil
            String maxIdSql = "SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM proiecte2";
            PreparedStatement maxIdPs = conn.prepareStatement(maxIdSql);
            ResultSet maxIdRs = maxIdPs.executeQuery();
            maxIdRs.next();
            int nextId = maxIdRs.getInt("next_id");
            
            String sql = "INSERT INTO proiecte2 (id, nume, descriere, start, end) " +
                         "VALUES (?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, nextId);
            ps.setString(2, nume);
            ps.setString(3, descriere);
            ps.setString(4, start);
            ps.setString(5, end);
            
            ps.executeUpdate();
            
            // Afișează un mesaj pentru utilizator
            request.getSession().setAttribute("message", 
                "Proiectul a fost adăugat, dar va fi vizibil pentru toți utilizatorii.");
            
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}