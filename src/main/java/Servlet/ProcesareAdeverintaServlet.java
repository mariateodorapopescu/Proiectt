package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import bean.MyUser;

public class ProcesareAdeverintaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Genereaza o adeverinta in format PDF si o trimite direct in browser-ul utilizatorului pentru descarcare.
     * @param conn Conexiunea la baza de date
     * @param idAdeverinta ID-ul adeverintei de generat
     * @param response Obiectul HttpServletResponse pentru trimiterea datelor catre browser
     * @throws SQLException Daca apare o eroare in timpul interogarii bazei de date
     * @throws IOException Daca apare o eroare la scrierea PDF-ului in stream
     */
    public void genereazaAdeverinta(Connection conn, int idAdeverinta, HttpServletResponse response) throws SQLException, IOException {
        // Metoda genereazaAdeverinta rămâne neschimbată
        // (codil existent pentru generarea PDF)
        String sql = "SELECT a.*, ta.denumire as tip_adeverinta, u.nume, u.prenume, u.cnp, u.data_nasterii, " +
                    "u.adresa, u.email, u.telefon, d.nume_dep, tp.denumire as pozitie, u.salariu_brut, u.data_ang " +
                    "FROM adeverinte a " +
                    "JOIN tip_adev ta ON a.tip = ta.id " +
                    "JOIN useri u ON a.id_ang = u.id " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "JOIN tipuri tp ON u.tip = tp.tip " +
                    "WHERE a.id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idAdeverinta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Setam header-ele pentru descarcare
                    response.setContentType("application/pdf");
                    String fileName = String.format("adeverinta_%d_%s_%s.pdf", 
                            idAdeverinta, 
                            rs.getString("nume").toLowerCase(), 
                            rs.getString("prenume").toLowerCase());
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                    
                    try {
                        // Cream documentul PDF direct in output stream
                        com.itextpdf.text.Document document = new com.itextpdf.text.Document(com.itextpdf.text.PageSize.A4);
                        com.itextpdf.text.pdf.PdfWriter writer = com.itextpdf.text.pdf.PdfWriter.getInstance(document, response.getOutputStream());
                        document.open();
                        
                        // Stiluri pentru text
                        com.itextpdf.text.Font titleFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 18, com.itextpdf.text.Font.BOLD);
                        com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 12, com.itextpdf.text.Font.BOLD);
                        com.itextpdf.text.Font normalFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 12, com.itextpdf.text.Font.NORMAL);
                        
                        // Titlu
                        com.itextpdf.text.Paragraph title = new com.itextpdf.text.Paragraph("ADEVERINTA", titleFont);
                        title.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                        document.add(title);
                        
                        // Numar adeverinta si data
                        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd.MM.yyyy");
                        String dataEmitere = dateFormat.format(new java.util.Date());
                        com.itextpdf.text.Paragraph nrAdeverinta = new com.itextpdf.text.Paragraph(
                                "Nr. " + idAdeverinta + " / " + dataEmitere, normalFont);
                        nrAdeverinta.setAlignment(com.itextpdf.text.Element.ALIGN_RIGHT);
                        document.add(nrAdeverinta);
                        
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        // Continutul adeverintei in functie de tipul ei
                        int tipAdeverinta = rs.getInt("tip");
                        String numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
                        String cnp = rs.getString("cnp");
                        String functie = rs.getString("pozitie");
                        String departament = rs.getString("nume_dep");
                        String motiv = rs.getString("pentru_servi");
                        
                        com.itextpdf.text.Paragraph content = new com.itextpdf.text.Paragraph();
                        content.setAlignment(com.itextpdf.text.Element.ALIGN_JUSTIFIED);
                        
                        switch (tipAdeverinta) {
                            case 1: // Adeverinta de salariat
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 2: // Adeverinta de venit
                                int salariu = rs.getInt("salariu_brut");
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", are un salariu brut de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(String.format("%,d", salariu) + " RON", headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 3: // Adeverinta medicala
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" si beneficiaza de asigurare medicala conform legii.", normalFont));
                                content.add(new com.itextpdf.text.Chunk("\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 4: // Adeverinta de concediu
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", se afla in concediu aprobat, conform solicitarii sale.", normalFont));
                                content.add(new com.itextpdf.text.Chunk("\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 5: // Adeverinta de experienta
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", a fost/este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" si are o experienta profesionala totala in compania noastra de ", normalFont));
                                
                                // Calculam experienta - verificam daca avem campul data_ang in useri
                                String dataAngajarii = rs.getString("data_ang") != null ? rs.getString("data_ang") : "N/A";
                                content.add(new com.itextpdf.text.Chunk(dataAngajarii, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            default: // Alte tipuri de adeverinte
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, adeverim ca ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" in cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                        }
                        
                        document.add(content);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        // Data si semnatura
                        com.itextpdf.text.Paragraph dataEmitereParagraph = new com.itextpdf.text.Paragraph("Data: " + dataEmitere, normalFont);
                        dataEmitereParagraph.setAlignment(com.itextpdf.text.Element.ALIGN_LEFT);
                        document.add(dataEmitereParagraph);
                        
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        com.itextpdf.text.Paragraph semnatura = new com.itextpdf.text.Paragraph("Director Resurse Umane,", normalFont);
                        semnatura.setAlignment(com.itextpdf.text.Element.ALIGN_RIGHT);
                        document.add(semnatura);
                        
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        com.itextpdf.text.Paragraph numeSemnatura = new com.itextpdf.text.Paragraph("_____________________", normalFont);
                        numeSemnatura.setAlignment(com.itextpdf.text.Element.ALIGN_RIGHT);
                        document.add(numeSemnatura);
                        
                        // Footer
                        com.itextpdf.text.Paragraph footer = new com.itextpdf.text.Paragraph(
                                "Acest document este valabil 30 de zile de la data emiterii.", 
                                new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 10, com.itextpdf.text.Font.ITALIC));
                        footer.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                        document.add(footer);
                        
                        // Informatii juridice
                        com.itextpdf.text.Paragraph legal = new com.itextpdf.text.Paragraph(
                                "Acest document a fost generat automat si nu necesita semnatura olografa conform art. 5 din Legea 455/2001.", 
                                new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 8, com.itextpdf.text.Font.ITALIC));
                        legal.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                        document.add(legal);
                        
                        document.close();
                        
                        // Marcam adeverinta ca generata in baza de date
                        try (PreparedStatement updateStmt = conn.prepareStatement(
                                "UPDATE adeverinte SET pdf_generated = 1 WHERE id = ?")) {
                            updateStmt.setInt(1, idAdeverinta);
                            updateStmt.executeUpdate();
                        }
                    } catch (com.itextpdf.text.DocumentException e) {
                        throw new IOException("Eroare la generarea PDF-ului: " + e.getMessage(), e);
                    }
                }
            }
        }
    }
    
    /**
     * Metoda pentru generarea directa a PDF-ului cand este solicitat prin GET
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        String idAdeverintaStr = request.getParameter("id");
        
        if (idAdeverintaStr == null || idAdeverintaStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID adeverinta lipsa");
            return;
        }
        
        int idAdeverinta = Integer.parseInt(idAdeverintaStr);
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Verificam daca adeverinta apartine utilizatorului curent sau daca utilizatorul este director/sef
            String sql = "SELECT a.status, u.id as id_ang, u.id_dep " +
                        "FROM adeverinte a " +
                        "JOIN useri u ON a.id_ang = u.id " +
                        "WHERE a.id = ? AND (a.id_ang = ? OR ? IN (0, 3))";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idAdeverinta);
                pstmt.setInt(2, currentUser.getId());
                pstmt.setInt(3, currentUser.getTip());
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // Verificare suplimentara pentru sefi de departament
                        int idDep = rs.getInt("id_dep");
                        int status = rs.getInt("status");
                        
                        if (currentUser.getTip() == 3 && idDep != currentUser.getDepartament()) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Nu aveti permisiunea sa accesati aceasta adeverinta");
                            return;
                        }
                        
                        // Verificam daca adeverinta este aprobata
                        if (status == 2) {
                            // Generam PDF-ul si il trimitem
                            genereazaAdeverinta(conn, idAdeverinta, response);
                        } else {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Adeverinta nu este aprobata final");
                        }
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Adeverinta nu exista sau nu aveti permisiunea sa o accesati");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Eroare la generarea adeverintei: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Metoda pentru procesarea adeverintelor (aprobare/respingere)
     * Aceasta metoda implementeaza flow-ul complet pentru diferite tipuri de angajati
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        HttpSession session = request.getSession();
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            json.put("success", false);
            json.put("message", "Sesiune invalida. Va rugam sa va autentificati din nou.");
            out.print(json.toString());
            return;
        }
        
        int userTip = currentUser.getTip();
        int userId = currentUser.getId();
        
        // Verificare permisiuni - doar directorul sau șefii pot procesa cereri
        if (userTip != 0 && userTip != 3) {
            json.put("success", false);
            json.put("message", "Nu aveti permisiuni pentru aceasta actiune");
            out.print(json.toString());
            return;
        }
        
        // Verificare parametri
        String idAdeverintaStr = request.getParameter("id");
        String statusStr = request.getParameter("status");
        
        if (idAdeverintaStr == null || statusStr == null) {
            json.put("success", false);
            json.put("message", "Parametri lipsa sau invalizi");
            out.print(json.toString());
            return;
        }
        
        int idAdeverinta;
        int newStatus;
        
        try {
            idAdeverinta = Integer.parseInt(idAdeverintaStr);
            newStatus = Integer.parseInt(statusStr);
        } catch (NumberFormatException e) {
            json.put("success", false);
            json.put("message", "Format invalid pentru parametri");
            out.print(json.toString());
            return;
        }
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            System.out.println("Procesare adeverință #" + idAdeverinta + " cu status nou " + newStatus + " de către utilizator tip " + userTip);
            
            // Obținem informații despre adeverință și angajat
            int idAngajat = 0;
            int currentStatus = 0;
            int departamentAngajat = 0;
            int angajatTip = 0;
            
            String checkSql = "SELECT a.id_ang, a.status, u.tip as angajat_tip, u.id_dep " +
                             "FROM adeverinte a " +
                             "JOIN useri u ON a.id_ang = u.id " +
                             "WHERE a.id = ?";
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, idAdeverinta);
                
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (!rs.next()) {
                        json.put("success", false);
                        json.put("message", "Adeverința nu a fost găsită.");
                        out.print(json.toString());
                        conn.rollback();
                        return;
                    }
                    
                    idAngajat = rs.getInt("id_ang");
                    currentStatus = rs.getInt("status");
                    angajatTip = rs.getInt("angajat_tip");
                    departamentAngajat = rs.getInt("id_dep");
                    
                    System.out.println("Adeverință pentru angajat #" + idAngajat + ", status curent: " + currentStatus);
                    System.out.println("Tip angajat: " + angajatTip + ", departament: " + departamentAngajat);
                }
            }
            
            boolean allowedToProcess = false;
            
            // SIMPLIFICĂM LOGICA - doar verificăm permisiunile de bază
            if (userTip == 3) { // Șef departament
                // Verificăm dacă angajatul este în departamentul șefului
                if (departamentAngajat == currentUser.getDepartament()) {
                    // Permitem procesarea doar pentru status 0 -> 1 sau 0 -> -1
                    if (currentStatus == 0 && (newStatus == 1 || newStatus == -1)) {
                        allowedToProcess = true;
                        System.out.println("Șef aprobă/respinge adeverință din departamentul său");
                    } else {
                        json.put("success", false);
                        json.put("message", "Șeful poate procesa doar adeverințe în starea inițială (0)");
                        out.print(json.toString());
                        conn.rollback();
                        return;
                    }
                } else {
                    json.put("success", false);
                    json.put("message", "Nu puteți procesa adeverințe pentru angajați din alte departamente");
                    out.print(json.toString());
                    conn.rollback();
                    return;
                }
            } 
            else if (userTip == 0) { // Director
                // Directorul poate procesa orice
                if (idAngajat == userId) {
                    // Auto-aprobare sau respingere
                    if (newStatus == 2 || newStatus == -1) {
                        allowedToProcess = true;
                        System.out.println("Director auto-aprobă/respinge propria adeverință");
                    }
                }
                else if (currentStatus == 1 && (newStatus == 2 || newStatus == -2)) {
                    // Aprobare finală sau respingere după șef
                    allowedToProcess = true;
                    System.out.println("Director aprobă/respinge final adeverință după aprobarea șefului");
                }
                else if (currentStatus == 0 && (angajatTip == 3 || (angajatTip >= 10 && angajatTip <= 15))) {
                    // Aprobare sau respingere directă pentru șefi/manageri
                    if (newStatus == 2 || newStatus == -1) {
                        allowedToProcess = true;
                        System.out.println("Director aprobă/respinge direct adeverință pentru șef/manager");
                    }
                }
                
                if (!allowedToProcess) {
                    json.put("success", false);
                    json.put("message", "Operație nepermisă: status " + currentStatus + " -> " + newStatus);
                    out.print(json.toString());
                    conn.rollback();
                    return;
                }
            }
            
            // Actualizare status adeverință
            String sql = "UPDATE adeverinte SET status = ?, modif = CURDATE() WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, newStatus);
                pstmt.setInt(2, idAdeverinta);
                int updated = pstmt.executeUpdate();
                System.out.println("Rânduri actualizate: " + updated);
                
                if (updated == 0) {
                    json.put("success", false);
                    json.put("message", "Nu s-a putut actualiza statusul adeverinței");
                    out.print(json.toString());
                    conn.rollback();
                    return;
                }
            }
            
            // Dacă șeful aprobă, notifică directorul 
            if (userTip == 3 && newStatus == 1) {
                notificaDirector(conn, idAdeverinta);
            }
            
            // Notificăm angajatul în toate cazurile
            notificaAngajat(conn, idAdeverinta, idAngajat, newStatus);
            
            conn.commit();
            json.put("success", true);
            
            if (newStatus == 2) {
                json.put("message", "Cererea a fost aprobată. PDF-ul poate fi descărcat din secțiunea de adeverințe.");
                json.put("id", idAdeverinta);
            } else if (newStatus == 1) {
                json.put("message", "Cererea a fost aprobată și trimisă directorului pentru aprobarea finală.");
            } else if (newStatus < 0) {
                json.put("message", "Cererea a fost respinsă.");
            } else {
                json.put("message", "Statusul cererii a fost actualizat.");
            }
            
        } catch (SQLException | ClassNotFoundException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la procesare: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { 
                    e.printStackTrace(); 
                }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
    
    private void notificaDirector(Connection conn, int idAdeverinta) throws SQLException {
        createNotificationsTableIfNeeded(conn);
        
        String sql = "SELECT id FROM useri WHERE tip = 0";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int idDirector = rs.getInt("id");
                    
                    String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
                    
                    String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                                    "VALUES (?, 'APROBARE_ADEVERINTA', ?)";
                    try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
                        notifPstmt.setInt(1, idDirector);
                        notifPstmt.setString(2, "Aveti o adeverinta noua de aprobat: " + adeverintaInfo);
                        notifPstmt.executeUpdate();
                    }
                }
            }
        }
    }
    
    private void notificaAngajat(Connection conn, int idAdeverinta, int idAngajat, int status) throws SQLException {
        createNotificationsTableIfNeeded(conn);
        
        String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
        String mesaj = "";
        
        switch (status) {
            case 1:
                mesaj = "Cererea dumneavoastra de adeverinta a fost aprobata de seful de departament si asteapta aprobarea directorului: " + adeverintaInfo;
                break;
            case 2:
                mesaj = "Cererea dumneavoastra de adeverinta a fost aprobata si este disponibila pentru descarcare: " + adeverintaInfo;
                break;
            case -1:
                mesaj = "Cererea dumneavoastra de adeverinta a fost respinsa: " + adeverintaInfo;
                break;
            case -2:
                mesaj = "Cererea dumneavoastra de adeverinta a fost respinsa de director: " + adeverintaInfo;
                break;
            default:
                mesaj = "Status-ul cererii dumneavoastra de adeverinta a fost actualizat: " + adeverintaInfo;
        }
        
        String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                         "VALUES (?, 'STATUS_ADEVERINTA', ?)";
        try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
            notifPstmt.setInt(1, idAngajat);
            notifPstmt.setString(2, mesaj);
            notifPstmt.executeUpdate();
        }
    }
    
    private String getAdeverintaInfo(Connection conn, int idAdeverinta) throws SQLException {
        String info = "";
        String sql = "SELECT ta.denumire, a.pentru_servi " +
                    "FROM adeverinte a " +
                    "JOIN tip_adev ta ON a.tip = ta.id " +
                    "WHERE a.id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idAdeverinta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    info = rs.getString("denumire") + " pentru " + rs.getString("pentru_servi");
                }
            }
        }
        
        return info;
    }
    
    private void createNotificationsTableIfNeeded(Connection conn) throws SQLException {
        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'notificari_general'")) {
            ResultSet rs = checkStmt.executeQuery();
            if (!rs.next()) {
                try (PreparedStatement createStmt = conn.prepareStatement(
                        "CREATE TABLE notificari_general (" +
                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "id_destinatar INT NOT NULL, " +
                        "tip VARCHAR(50) NOT NULL, " +
                        "mesaj VARCHAR(255) NOT NULL, " +
                        "data_creare TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "citit BOOLEAN DEFAULT FALSE, " +
                        "FOREIGN KEY (id_destinatar) REFERENCES useri(id))")) {
                    createStmt.executeUpdate();
                }
            }
        }
    }
}