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
     * Generează o adeverință în format PDF și o trimite direct în browser-ul utilizatorului pentru descărcare.
     * @param conn Conexiunea la baza de date
     * @param idAdeverinta ID-ul adeverinței de generat
     * @param response Obiectul HttpServletResponse pentru trimiterea datelor către browser
     * @throws SQLException Dacă apare o eroare în timpul interogării bazei de date
     * @throws IOException Dacă apare o eroare la scrierea PDF-ului în stream
     */
    public void genereazaAdeverinta(Connection conn, int idAdeverinta, HttpServletResponse response) throws SQLException, IOException {
        // Obținem informațiile necesare pentru generarea adeverinței
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
                    // Setăm header-ele pentru descărcare
                    response.setContentType("application/pdf");
                    String fileName = String.format("adeverinta_%d_%s_%s.pdf", 
                            idAdeverinta, 
                            rs.getString("nume").toLowerCase(), 
                            rs.getString("prenume").toLowerCase());
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                    
                    try {
                        // Creăm documentul PDF direct în output stream
                        com.itextpdf.text.Document document = new com.itextpdf.text.Document(com.itextpdf.text.PageSize.A4);
                        com.itextpdf.text.pdf.PdfWriter writer = com.itextpdf.text.pdf.PdfWriter.getInstance(document, response.getOutputStream());
                        document.open();
                        
                        // Stiluri pentru text
                        com.itextpdf.text.Font titleFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 18, com.itextpdf.text.Font.BOLD);
                        com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 12, com.itextpdf.text.Font.BOLD);
                        com.itextpdf.text.Font normalFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 12, com.itextpdf.text.Font.NORMAL);
                        
                        // Titlu
                        com.itextpdf.text.Paragraph title = new com.itextpdf.text.Paragraph("ADEVERINȚĂ", titleFont);
                        title.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                        document.add(title);
                        
                        // Număr adeverință și data
                        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd.MM.yyyy");
                        String dataEmitere = dateFormat.format(new java.util.Date());
                        com.itextpdf.text.Paragraph nrAdeverinta = new com.itextpdf.text.Paragraph(
                                "Nr. " + idAdeverinta + " / " + dataEmitere, normalFont);
                        nrAdeverinta.setAlignment(com.itextpdf.text.Element.ALIGN_RIGHT);
                        document.add(nrAdeverinta);
                        
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        // Conținutul adeverinței în funcție de tipul ei
                        int tipAdeverinta = rs.getInt("tip");
                        String numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
                        String cnp = rs.getString("cnp");
                        String functie = rs.getString("pozitie");
                        String departament = rs.getString("nume_dep");
                        String motiv = rs.getString("pentru_servi");
                        
                        com.itextpdf.text.Paragraph content = new com.itextpdf.text.Paragraph();
                        content.setAlignment(com.itextpdf.text.Element.ALIGN_JUSTIFIED);
                        
                        switch (tipAdeverinta) {
                            case 1: // Adeverință de salariat
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 2: // Adeverință de venit
                                int salariu = rs.getInt("salariu_brut");
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", are un salariu brut de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(String.format("%,d", salariu) + " RON", headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 3: // Adeverință medicală
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" și beneficiază de asigurare medicală conform legii.", normalFont));
                                content.add(new com.itextpdf.text.Chunk("\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 4: // Adeverință de concediu
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", se află în concediu aprobat, conform solicitării sale.", normalFont));
                                content.add(new com.itextpdf.text.Chunk("\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            case 5: // Adeverință de experiență
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", a fost/este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" și are o experiență profesională totală în compania noastră de ", normalFont));
                                
                                // Calculăm experiența - verificăm dacă avem câmpul data_ang în useri
                                String dataAngajarii = rs.getString("data_ang") != null ? rs.getString("data_ang") : "N/A";
                                content.add(new com.itextpdf.text.Chunk(dataAngajarii, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                                
                            default: // Alte tipuri de adeverințe
                                content.add(new com.itextpdf.text.Chunk("Prin prezenta, adeverim că ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(numePrenume, headerFont));
                                content.add(new com.itextpdf.text.Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(functie, headerFont));
                                content.add(new com.itextpdf.text.Chunk(" în cadrul departamentului ", normalFont));
                                content.add(new com.itextpdf.text.Chunk(departament, headerFont));
                                content.add(new com.itextpdf.text.Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                                break;
                        }
                        
                        document.add(content);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        document.add(com.itextpdf.text.Chunk.NEWLINE);
                        
                        // Data și semnătură
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
                        
                        // Informații juridice
                        com.itextpdf.text.Paragraph legal = new com.itextpdf.text.Paragraph(
                                "Acest document a fost generat automat și nu necesită semnătură olografă conform art. 5 din Legea 455/2001.", 
                                new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.TIMES_ROMAN, 8, com.itextpdf.text.Font.ITALIC));
                        legal.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                        document.add(legal);
                        
                        document.close();
                        
                        // Marcăm adeverința ca generată în baza de date
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
    
    
        protected void doPost(HttpServletRequest request, HttpServletResponse response) 
                throws ServletException, IOException {
            
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject json = new JSONObject();
            
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("currentUser") == null) {
                json.put("success", false);
                json.put("message", "Sesiune invalidă. Vă rugăm să vă autentificați din nou.");
                out.print(json.toString());
                return;
            }
            
            MyUser currentUser = (MyUser) session.getAttribute("currentUser");
            int userTip = currentUser.getTip();
            int userId = currentUser.getId();
            int userDepartment = currentUser.getDepartament();
            
            // Verificare permisiuni
            if (userTip != 0 && userTip != 3) {
                json.put("success", false);
                json.put("message", "Nu aveți permisiuni pentru această acțiune");
                out.print(json.toString());
                return;
            }
            
            // Verificare parametri
            String idAdeverintaStr = request.getParameter("id");
            String statusStr = request.getParameter("status");
            
            if (idAdeverintaStr == null || statusStr == null) {
                json.put("success", false);
                json.put("message", "Parametri lipsă sau invalizi");
                out.print(json.toString());
                return;
            }
            
            int idAdeverinta;
            int status;
            
            try {
                idAdeverinta = Integer.parseInt(idAdeverintaStr);
                status = Integer.parseInt(statusStr);
            } catch (NumberFormatException e) {
                json.put("success", false);
                json.put("message", "Format invalid pentru parametri");
                out.print(json.toString());
                return;
            }
            
            Connection conn = null;
            
            try {
                // Conectare la baza de date
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                conn.setAutoCommit(false); // Activăm tranzacțiile
                
                // Verificăm cererea și permisiunile
                String checkSql = "SELECT a.id_ang, a.status, u.id_dep, u.tip " +
                                 "FROM adeverinte a " +
                                 "JOIN useri u ON a.id_ang = u.id " +
                                 "WHERE a.id = ?";
                                 
                boolean allowedToProcess = false;
                int idAngajat = 0;
                int currentStatus = 0;
                int angajatDep = 0;
                int angajatTip = 0;
                
                try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                    checkStmt.setInt(1, idAdeverinta);
                    
                    try (ResultSet rs = checkStmt.executeQuery()) {
                        if (rs.next()) {
                            idAngajat = rs.getInt("id_ang");
                            currentStatus = rs.getInt("status");
                            angajatDep = rs.getInt("id_dep");
                            angajatTip = rs.getInt("tip");
                            
                            // Verificare permisiuni
                            if (userTip == 3) { // Șef de departament
                                // Verificăm dacă adeverința aparține unui angajat din departamentul șefului
                                if (angajatDep == userDepartment) {
                                    // Verificăm dacă status-ul actual este 0 (neprocesat) 
                                    // și dacă noul status este 1 (aprobat) sau -1 (respins)
                                    if (currentStatus == 0 && (status == 1 || status == -1)) {
                                        allowedToProcess = true;
                                    }
                                }
                            } else if (userTip == 0) { // Director
                                // Directorul poate aproba sau respinge orice cerere
                                allowedToProcess = true;
                            }
                        }
                    }
                }
                
                if (!allowedToProcess) {
                    json.put("success", false);
                    json.put("message", "Nu aveți permisiunea de a procesa această cerere sau cererea nu există");
                    out.print(json.toString());
                    conn.rollback();
                    return;
                }
                
                // Actualizare status adeverință
                String sql = "UPDATE adeverinte SET status = ?, modif = CURDATE() WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, status);
                    pstmt.setInt(2, idAdeverinta);
                    int rowsUpdated = pstmt.executeUpdate();
                    
                    if (rowsUpdated == 0) {
                        json.put("success", false);
                        json.put("message", "Adeverința nu a putut fi actualizată");
                        conn.rollback();
                        out.print(json.toString());
                        return;
                    }
                }
                
                // Notificare utilizator (opțional)
                String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) VALUES (?, ?, ?)";
                try (PreparedStatement notifStmt = conn.prepareStatement(notifSql)) {
                    String mesaj = "";
                    if (status == 1) {
                        mesaj = "Cererea dumneavoastră de adeverință a fost aprobată de șeful de departament și așteaptă aprobarea finală";
                    } else if (status == 2) {
                        mesaj = "Cererea dumneavoastră de adeverință a fost aprobată final și poate fi descărcată";
                    } else if (status < 0) {
                        mesaj = "Cererea dumneavoastră de adeverință a fost respinsă";
                    }
                    
                    notifStmt.setInt(1, idAngajat);
                    notifStmt.setString(2, "STATUS_ADEVERINTA");
                    notifStmt.setString(3, mesaj);
                    
                    try {
                        notifStmt.executeUpdate();
                    } catch (SQLException e) {
                        // Ignorăm erorile de notificare - probabil tabela nu există
                        System.out.println("Avertisment: notificarea nu a putut fi trimisă: " + e.getMessage());
                    }
                }
                
                conn.commit();
                json.put("success", true);
                
                if (status > 0) {
                    json.put("message", "Cererea a fost aprobată cu succes!");
                } else {
                    json.put("message", "Cererea a fost respinsă cu succes!");
                }
                
            } catch (Exception e) {
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
        // Verificăm și creăm tabela dacă nu există
        createNotificationsTableIfNeeded(conn);
        
        // Găsește directorul
        String sql = "SELECT id FROM useri WHERE tip = 0";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int idDirector = rs.getInt("id");
                    
                    // Obține informații despre cerere pentru un mesaj mai descriptiv
                    String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
                    
                    // Trimite notificare
                    String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                                    "VALUES (?, 'APROBARE_ADEVERINTA', ?)";
                    try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
                        notifPstmt.setInt(1, idDirector);
                        notifPstmt.setString(2, "Aveți o adeverință nouă de aprobat: " + adeverintaInfo);
                        notifPstmt.executeUpdate();
                    }
                }
            }
        }
    }
    
    private void notificaAngajat(Connection conn, int idAdeverinta, int idAngajat, int status) throws SQLException {
        // Verificăm și creăm tabela dacă nu există
        createNotificationsTableIfNeeded(conn);
        
        // Obține informații despre cerere pentru un mesaj mai descriptiv
        String adeverintaInfo = getAdeverintaInfo(conn, idAdeverinta);
        String mesaj = "";
        
        switch (status) {
            case 1:
                mesaj = "Cererea dumneavoastră de adeverință a fost aprobată de șeful de departament și așteaptă aprobarea directorului: " + adeverintaInfo;
                break;
            case 2:
                mesaj = "Cererea dumneavoastră de adeverință a fost aprobată și este disponibilă pentru descărcare: " + adeverintaInfo;
                break;
            case -1:
                mesaj = "Cererea dumneavoastră de adeverință a fost respinsă: " + adeverintaInfo;
                break;
            case -2:
                mesaj = "Cererea dumneavoastră de adeverință a fost respinsă de director: " + adeverintaInfo;
                break;
            default:
                mesaj = "Status-ul cererii dumneavoastră de adeverință a fost actualizat: " + adeverintaInfo;
        }
        
        // Trimite notificare
        String notifSql = "INSERT INTO notificari_general (id_destinatar, tip, mesaj) " +
                         "VALUES (?, 'STATUS_ADEVERINTA', ?)";
        try (PreparedStatement notifPstmt = conn.prepareStatement(notifSql)) {
            notifPstmt.setInt(1, idAngajat);
            notifPstmt.setString(2, mesaj);
            notifPstmt.executeUpdate();
        }
    }
    
    private String getAdeverintaInfo(Connection conn, int idAdeverinta) throws SQLException {
        // Obține detalii despre adeverință pentru mesaje mai descriptive
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
        // Verifică dacă tabela notificari_general există
        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'notificari_general'")) {
            ResultSet rs = checkStmt.executeQuery();
            if (!rs.next()) {
                // Dacă tabela nu există, o creăm
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