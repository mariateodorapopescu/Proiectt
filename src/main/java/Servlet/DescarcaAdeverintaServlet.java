package Servlet;

import java.io.IOException;
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

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.pdf.PdfWriter;

import bean.MyUser;

public class DescarcaAdeverintaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
            response.sendRedirect("adeverinte_mele.jsp?error=true");
            return;
        }
        
        int idAdeverinta = Integer.parseInt(idAdeverintaStr);
        Connection conn = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Verificăm dacă adeverința aparține utilizatorului curent sau dacă utilizatorul este director/șef
            String sql = "SELECT a.*, ta.denumire as tip_adeverinta, u.nume, u.prenume, u.cnp, " +
                        "u.adresa, u.email, u.telefon, d.nume_dep, tp.denumire as pozitie, " +
                        "u.salariu_brut, u.data_ang, u.id as id_ang, u.id_dep " +
                        "FROM adeverinte a " +
                        "JOIN tip_adev ta ON a.tip = ta.id " +
                        "JOIN useri u ON a.id_ang = u.id " +
                        "JOIN departament d ON u.id_dep = d.id_dep " +
                        "JOIN tipuri tp ON u.tip = tp.tip " +
                        "WHERE a.id = ? AND a.status = 2 AND (a.id_ang = ? OR ? IN (0, 3))";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idAdeverinta);
                pstmt.setInt(2, currentUser.getId());
                pstmt.setInt(3, currentUser.getTip());
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // Verificare suplimentară pentru șefi de departament
                        int idDep = rs.getInt("id_dep");
                        if (currentUser.getTip() == 3 && idDep != currentUser.getDepartament()) {
                            response.sendRedirect("adeverinte_mele.jsp?error=unauthorized");
                            return;
                        }
                        
                        // Generăm PDF-ul
                        generatePdf(rs, response);
                    } else {
                        response.sendRedirect("adeverinte_mele.jsp?error=unauthorized");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adeverinte_mele.jsp?error=" + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void generatePdf(ResultSet rs, HttpServletResponse response) 
            throws SQLException, IOException, DocumentException {
        
        // Setăm header-ele pentru descărcare
        response.setContentType("application/pdf");
        String fileName = String.format("adeverinta_%d_%s_%s.pdf", 
                rs.getInt("id"), 
                rs.getString("nume").toLowerCase(), 
                rs.getString("prenume").toLowerCase());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        
        // Cream documentul PDF
        Document document = new Document(PageSize.A4);
        PdfWriter.getInstance(document, response.getOutputStream());
        document.open();
        
        // Stiluri pentru text
        Font titleFont = new Font(Font.FontFamily.TIMES_ROMAN, 18, Font.BOLD);
        Font headerFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.BOLD);
        Font normalFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.NORMAL);
        
        // Titlu
        Paragraph title = new Paragraph("ADEVERINȚĂ", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        
        // Număr adeverință și data
        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd.MM.yyyy");
        String dataEmitere = dateFormat.format(new java.util.Date());
        Paragraph nrAdeverinta = new Paragraph(
                "Nr. " + rs.getInt("id") + " / " + dataEmitere, normalFont);
        nrAdeverinta.setAlignment(Element.ALIGN_RIGHT);
        document.add(nrAdeverinta);
        
        document.add(Chunk.NEWLINE);
        document.add(Chunk.NEWLINE);
        
        // Conținutul adeverinței
        int tipAdeverinta = rs.getInt("tip");
        String numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
        String cnp = rs.getString("cnp");
        String functie = rs.getString("pozitie");
        String departament = rs.getString("nume_dep");
        String motiv = rs.getString("pentru_servi");
        
        Paragraph content = new Paragraph();
        content.setAlignment(Element.ALIGN_JUSTIFIED);
        
        switch (tipAdeverinta) {
            case 1: // Adeverința de salariat
                content.add(new Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                content.add(new Chunk(numePrenume, headerFont));
                content.add(new Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                content.add(new Chunk(functie, headerFont));
                content.add(new Chunk(" în cadrul departamentului ", normalFont));
                content.add(new Chunk(departament, headerFont));
                content.add(new Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                break;
                
            case 2: // Adeverința de venit
                int salariu = rs.getInt("salariu_brut");
                content.add(new Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                content.add(new Chunk(numePrenume, headerFont));
                content.add(new Chunk(", CNP " + cnp + ", angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                content.add(new Chunk(functie, headerFont));
                content.add(new Chunk(" în cadrul departamentului ", normalFont));
                content.add(new Chunk(departament, headerFont));
                content.add(new Chunk(", are un salariu brut de ", normalFont));
                content.add(new Chunk(String.format("%,d", salariu) + " RON", headerFont));
                content.add(new Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                break;
                
            // Adăugați celelalte cazuri similare cu cele din servlet-urile existente
            
            default: // Adeverință generică
                content.add(new Chunk("Prin prezenta, adeverim că ", normalFont));
                content.add(new Chunk(numePrenume, headerFont));
                content.add(new Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                content.add(new Chunk(functie, headerFont));
                content.add(new Chunk(" în cadrul departamentului ", normalFont));
                content.add(new Chunk(departament, headerFont));
                content.add(new Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                break;
        }
        
        document.add(content);
        document.add(Chunk.NEWLINE);
        document.add(Chunk.NEWLINE);
        
        // Data și semnătura
        Paragraph dataEmitereParagraph = new Paragraph("Data: " + dataEmitere, normalFont);
        dataEmitereParagraph.setAlignment(Element.ALIGN_LEFT);
        document.add(dataEmitereParagraph);
        
        document.add(Chunk.NEWLINE);
        document.add(Chunk.NEWLINE);
        
        Paragraph semnatura = new Paragraph("Director Resurse Umane,", normalFont);
        semnatura.setAlignment(Element.ALIGN_RIGHT);
        document.add(semnatura);
        
        document.add(Chunk.NEWLINE);
        
        Paragraph numeSemnatura = new Paragraph("_____________________", normalFont);
        numeSemnatura.setAlignment(Element.ALIGN_RIGHT);
        document.add(numeSemnatura);
        
        // Footer
        Paragraph footer = new Paragraph(
                "Acest document este valabil 30 de zile de la data emiterii.", 
                new Font(Font.FontFamily.TIMES_ROMAN, 10, Font.ITALIC));
        footer.setAlignment(Element.ALIGN_CENTER);
        document.add(footer);
        
        document.close();
        
        // Încercăm să actualizăm baza de date pentru a marca adeverința ca generată
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            // Verificăm dacă există coloana pdf_generated
            boolean hasColumn = false;
            try (ResultSet rsColumns = conn.getMetaData().getColumns(null, null, "adeverinte", "pdf_generated")) {
                hasColumn = rsColumns.next();
            }
            
            if (hasColumn) {
                try (PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE adeverinte SET pdf_generated = 1 WHERE id = ?")) {
                    updateStmt.setInt(1, rs.getInt("id"));
                    updateStmt.executeUpdate();
                }
            }
            conn.close();
        } catch (SQLException e) {
            // Ignorăm eroarea dacă nu putem actualiza - PDF-ul a fost deja generat
            e.printStackTrace();
        }
    }
}