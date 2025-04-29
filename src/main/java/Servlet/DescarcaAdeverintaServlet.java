package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.PdfWriter;

import bean.MyUser;

public class DescarcaAdeverintaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificare sesiune
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Preia informatii utilizator
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        String idAdeverintaStr = request.getParameter("id");
        
        if (idAdeverintaStr == null || idAdeverintaStr.isEmpty()) {
            response.sendRedirect("adeverinte_mele.jsp?error=invalid_id");
            return;
        }
        
        int idAdeverinta = Integer.parseInt(idAdeverintaStr);
        
        // Variabile pentru preluarea datelor
        String numePrenume = "";
        String cnp = "";
        String functie = "";
        String departament = "";
        String motiv = "";
        int tipAdeverinta = 0;
        int salariu = 0;
        String dataAngajarii = "";
        
        Connection conn = null;
        try {
            // Conectare la baza de date
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Interogare pentru adeverinta
            String sql = "SELECT a.*, ta.denumire as tip_adeverinta, u.nume, u.prenume, u.cnp, " +
                        "u.salariu_brut, u.data_ang, d.nume_dep, tp.denumire as pozitie " +
                        "FROM adeverinte a " +
                        "JOIN tip_adev ta ON a.tip = ta.id " +
                        "JOIN useri u ON a.id_ang = u.id " +
                        "JOIN departament d ON u.id_dep = d.id_dep " +
                        "JOIN tipuri tp ON u.tip = tp.tip " +
                        "WHERE a.id = ? AND a.status = 2 AND (a.id_ang = ? OR ? IN (0, 3))";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idAdeverinta);
            pstmt.setInt(2, currentUser.getId());
            pstmt.setInt(3, currentUser.getTip());
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                // Preia datele necesare
                numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
                cnp = rs.getString("cnp");
                functie = rs.getString("pozitie");
                departament = rs.getString("nume_dep");
                motiv = rs.getString("pentru_servi");
                tipAdeverinta = rs.getInt("tip");
                salariu = rs.getInt("salariu_brut");
                dataAngajarii = rs.getString("data_ang") != null ? rs.getString("data_ang") : "N/A";
            } else {
                response.sendRedirect("adeverinte_mele.jsp?error=not_found");
                return;
            }
            
            // Inchidere resurse
            rs.close();
            pstmt.close();
            
            // Genereaza PDF-ul folosind datele preluate
            generarePDF(response, idAdeverinta, numePrenume, cnp, functie, departament, 
                       motiv, tipAdeverinta, salariu, dataAngajarii);
            
        } catch (Exception e) {
            System.err.println("Eroare: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("adeverinte_mele.jsp?error=general");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignored */ }
            }
        }
    }
    
    private void generarePDF(HttpServletResponse response, int idAdeverinta, 
                           String numePrenume, String cnp, String functie, 
                           String departament, String motiv, int tipAdeverinta, 
                           int salariu, String dataAngajarii) 
            throws IOException {
        
        // Configurare temporar salvare in fisier (pentru depanare)
        String fileName = "adeverinta_" + idAdeverinta + ".pdf";
        File tempFile = new File(System.getProperty("java.io.tmpdir"), fileName);
        
        try {
            // Creaza document PDF
            Document document = new Document(PageSize.A4);
            PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(tempFile));
            document.open();
            
            // Adaugam continutul (acelasi ca inainte)
            Font titleFont = new Font(Font.FontFamily.TIMES_ROMAN, 18, Font.BOLD);
            Font headerFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.BOLD);
            Font normalFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.NORMAL);
            
            // Titlu
            Paragraph title = new Paragraph("ADEVERINȚĂ", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            
            // Data si numar
            java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd.MM.yyyy");
            String dataEmitere = dateFormat.format(new java.util.Date());
            Paragraph nrAdeverinta = new Paragraph("Nr. " + idAdeverinta + " / " + dataEmitere, normalFont);
            nrAdeverinta.setAlignment(Element.ALIGN_RIGHT);
            document.add(nrAdeverinta);
            
            document.add(Chunk.NEWLINE);
            document.add(Chunk.NEWLINE);
            
            // Continut adeverinta
            Paragraph content = new Paragraph();
            content.setAlignment(Element.ALIGN_JUSTIFIED);
            
            switch (tipAdeverinta) {
                case 1: // Adeverință de salariat
                    content.add(new Chunk("Prin prezenta, se adeverește faptul că ", normalFont));
                    content.add(new Chunk(numePrenume, headerFont));
                    content.add(new Chunk(", CNP " + cnp + ", este angajat(ă) al(a) companiei noastre, în funcția de ", normalFont));
                    content.add(new Chunk(functie, headerFont));
                    content.add(new Chunk(" în cadrul departamentului ", normalFont));
                    content.add(new Chunk(departament, headerFont));
                    content.add(new Chunk(".\n\nAceastă adeverință se eliberează pentru a-i servi la " + motiv + ".", normalFont));
                    break;
                    
                case 2: // Adeverință de venit
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
                    
                // Restul cazurilor (aceleasi ca anterior)
                default:
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
            
            // Data și semnătură
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
            
            // Informații juridice
            Paragraph legal = new Paragraph(
                    "Acest document a fost generat automat și nu necesită semnătură olografă conform art. 5 din Legea 455/2001.", 
                    new Font(Font.FontFamily.TIMES_ROMAN, 8, Font.ITALIC));
            legal.setAlignment(Element.ALIGN_CENTER);
            document.add(legal);
            
            document.close();
            writer.close();
            
            // Trimite fisierul catre browser
            trimiteFisier(response, tempFile, "adeverinta_" + idAdeverinta + ".pdf");
            
        } catch (Exception e) {
            System.err.println("Eroare la generarea PDF: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("adeverinte_mele.jsp?error=pdf_generation");
        } finally {
            // Sterge fisierul temporar
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }
    
    private void trimiteFisier(HttpServletResponse response, File file, String numeFisier) 
            throws IOException {
        
        response.reset();
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + numeFisier + "\"");
        response.setContentLength((int) file.length());
        
        try (FileInputStream input = new FileInputStream(file);
             OutputStream output = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead = -1;
            
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            
            output.flush();
        }
    }
}