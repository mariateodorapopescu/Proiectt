package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.MyUser;

public class AdaugaTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Setare encoding pentru caractere românești
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // Verificare sesiune
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        
        try {
            // Obține parametrii din form
            String nume = request.getParameter("nume");
            String supervizorStr = request.getParameter("supervizor");
            String idAngStr = request.getParameter("id_ang");
            String startStr = request.getParameter("start");
            String endStr = request.getParameter("end");
            String statusStr = request.getParameter("status");
            String idPrjStr = request.getParameter("id_prj");
            String descriere = request.getParameter("descriere");
            String taskTypeHidden = request.getParameter("task_type_hidden");
            String prioritateStr = request.getParameter("prioritate");
            
            // Validare parametri obligatorii
            if (nume == null || nume.trim().isEmpty()) {
                throw new IllegalArgumentException("Numele task-ului este obligatoriu!");
            }
            
            if (supervizorStr == null || idAngStr == null || startStr == null || 
                endStr == null || statusStr == null) {
                throw new IllegalArgumentException("Toate câmpurile obligatorii trebuie completate!");
            }
            
            // Conversie parametri
            int supervizor = Integer.parseInt(supervizorStr);
            int idAng = Integer.parseInt(idAngStr);
            int status = Integer.parseInt(statusStr);
            
            // Gestionare task personal vs proiect
            Integer idPrj = null;
            if ("project".equals(taskTypeHidden) && idPrjStr != null && !idPrjStr.trim().isEmpty()) {
                idPrj = Integer.parseInt(idPrjStr);
            }
            
            // Prioritate pentru task-uri personale
            Integer prioritate = null;
            if ("personal".equals(taskTypeHidden) && prioritateStr != null && !prioritateStr.trim().isEmpty()) {
                prioritate = Integer.parseInt(prioritateStr);
            }
            
            // Conversie date
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date startDate = sdf.parse(startStr);
            Date endDate = sdf.parse(endStr);
            
            // Validare date
            if (endDate.before(startDate)) {
                throw new IllegalArgumentException("Data de sfârșit nu poate fi înainte de data de început!");
            }
            
            // Validare pentru task-uri pe proiect
            if ("project".equals(taskTypeHidden) && idPrj == null) {
                throw new IllegalArgumentException("Pentru task-urile pe proiect trebuie să selectați un proiect!");
            }
            
            // Inserare în baza de date
            int taskId = insertTask(nume, supervizor, idAng, startDate, endDate, status, 
                                   idPrj, descriere, prioritate, taskTypeHidden);
            
            // Redirect cu mesaj de succes
            if (taskId > 0) {
                session.setAttribute("success_message", 
                    "Task-ul '" + nume + "' a fost creat cu succes!");
                response.sendRedirect("administrare_taskuri.jsp?action=list");
            } else {
                throw new SQLException("Nu s-a putut crea task-ul!");
            }
            
        } catch (NumberFormatException e) {
            handleError(request, response, "Parametri numerici invalizi: " + e.getMessage());
        } catch (ParseException e) {
            handleError(request, response, "Format de dată invalid: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            handleError(request, response, e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            handleError(request, response, "Eroare la baza de date: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            handleError(request, response, "Eroare neașteptată: " + e.getMessage());
        }
    }
    
    /**
     * Inserează task-ul în baza de date (folosind doar coloanele existente)
     */
    private int insertTask(String nume, int supervizor, int idAng, Date startDate, Date endDate, 
                          int status, Integer idPrj, String descriere, Integer prioritate, 
                          String taskType) throws SQLException {
        
        // Folosim doar coloanele care există deja în tabelul tasks
        String sql = "INSERT INTO tasks (nume, supervizor, id_ang, start, end, status, id_prj, descriere) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Verifică dacă utilizatorul asignat există și are permisiuni
            if (!validateUserAssignment(conn, idAng, supervizor, idPrj)) {
                throw new SQLException("Utilizatorul selectat nu poate fi asignat la acest task!");
            }
            
            // Verifică dacă proiectul este activ (pentru task-uri pe proiect)
            if (idPrj != null && !validateProjectStatus(conn, idPrj)) {
                throw new SQLException("Proiectul selectat nu este activ!");
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                
                // Setare parametri - folosim doar coloanele existente
                pstmt.setString(1, nume.trim());
                pstmt.setInt(2, supervizor);
                pstmt.setInt(3, idAng);
                pstmt.setDate(4, new java.sql.Date(startDate.getTime()));
                pstmt.setDate(5, new java.sql.Date(endDate.getTime()));
                pstmt.setInt(6, status);
                
                if (idPrj != null) {
                    pstmt.setInt(7, idPrj);
                } else {
                    pstmt.setNull(7, java.sql.Types.INTEGER);
                }
                
                // Pentru descriere, includem informații despre tip și prioritate în text
                String fullDescription = descriere != null ? descriere.trim() : "";
                if ("personal".equals(taskType)) {
                    String prioritateText = getPriorityText(prioritate);
                    fullDescription += "\n[TASK PERSONAL - Prioritate: " + prioritateText + "]";
                }
                
                if (!fullDescription.trim().isEmpty()) {
                    pstmt.setString(8, fullDescription);
                } else {
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                }
                
                int affectedRows = pstmt.executeUpdate();
                
                if (affectedRows > 0) {
                    try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            int taskId = generatedKeys.getInt(1);
                            
                            // Log the task creation (fără tabel separat)
                            System.out.println("Task created: ID=" + taskId + ", Type=" + taskType + ", Supervisor=" + supervizor);
                            
                            return taskId;
                        }
                    }
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Validează dacă utilizatorul poate fi asignat la task
     */
    private boolean validateUserAssignment(Connection conn, int idAng, int supervizor, Integer idPrj) 
            throws SQLException {
        
        // Verifică dacă utilizatorul există și este activ
        String userCheckSql = "SELECT u.id, t.ierarhie FROM useri u " +
                             "JOIN tipuri t ON u.tip = t.tip " +
                             "WHERE u.id = ? AND u.tip <> 34";  // Exclude admin accounts
        
        try (PreparedStatement pstmt = conn.prepareStatement(userCheckSql)) {
            pstmt.setInt(1, idAng);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    return false; // Utilizatorul nu există sau nu este valid
                }
            }
        }
        
        // Pentru task-uri pe proiect, verifică dacă utilizatorul face parte din echipa proiectului
        if (idPrj != null) {
            String teamCheckSql = "SELECT 1 FROM echipe e " +
                                 "WHERE e.id_prj = ? AND (e.supervizor = ? OR " +
                                 "EXISTS (SELECT 1 FROM useri u WHERE u.id = ? AND u.id_team = e.id))";
            
            try (PreparedStatement pstmt = conn.prepareStatement(teamCheckSql)) {
                pstmt.setInt(1, idPrj);
                pstmt.setInt(2, idAng);
                pstmt.setInt(3, idAng);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) {
                        // Utilizatorul nu face parte din echipa proiectului
                        // Permite totuși dacă supervizorul îl asignează explicit
                        return idAng == supervizor;
                    }
                }
            }
        }
        
        return true;
    }
    
    /**
     * Validează dacă proiectul este activ
     */
    private boolean validateProjectStatus(Connection conn, int idPrj) throws SQLException {
        String sql = "SELECT 1 FROM proiecte WHERE id = ? AND end >= CURDATE()";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idPrj);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }
    
    /**
     * Convertește codul priorității în text
     */
    private String getPriorityText(Integer prioritate) {
        if (prioritate == null) return "Normală";
        switch (prioritate) {
            case 1: return "Urgentă";
            case 2: return "Normală";
            case 3: return "Scăzută";
            default: return "Normală";
        }
    }
    
    /**
     * Gestionează erorile și redirecționează cu mesaj de eroare
     */
    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        session.setAttribute("error_message", errorMessage);
        
        // Păstrează valorile din formular pentru debugging
        session.setAttribute("form_data", request.getParameterMap());
        
        response.sendRedirect("administrare_taskuri.jsp?action=add&error=1");
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("administrare_taskuri.jsp?action=add");
    }
}