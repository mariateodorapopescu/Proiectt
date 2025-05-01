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
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sesiune invalida sau utilizator neautentificat");
            return;
        }
        
        // Preia informatii utilizator
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        
        // Verifica ambele posibile nume de parametri (id si idadev)
        String idAdeverintaStr = request.getParameter("id");
        if (idAdeverintaStr == null || idAdeverintaStr.isEmpty()) {
            idAdeverintaStr = request.getParameter("idadev");
        }
        
        if (idAdeverintaStr == null || idAdeverintaStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID adeverinta lipsa sau invalid");
            return;
        }
        
        // Log pentru debugging
        System.out.println("ID Adeverinta pentru descarcare: " + idAdeverintaStr);
        
        int idAdeverinta;
        try {
            idAdeverinta = Integer.parseInt(idAdeverintaStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID adeverinta nu este un numar valid");
            return;
        }
        
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
                        "u.salariu_brut, u.data_ang, d.nume_dep, tp.denumire as pozitie, a.pentru_servi " +
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
            
            // Log pentru debugging
            System.out.println("Executand query pentru id=" + idAdeverinta + ", user id=" + currentUser.getId() + ", tip=" + currentUser.getTip());
            
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
                
                System.out.println("Date gasite pentru adeverinta " + idAdeverinta + ": " + numePrenume);
            } else {
                System.out.println("Nu s-au gasit date pentru adeverinta " + idAdeverinta);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Adeverinta nu a fost gasita sau nu aveti acces la ea");
                return;
            }
            
            // Inchidere resurse
            rs.close();
            pstmt.close();
            
            // Genereaza PDF-ul direct in response
            generarePDFDirect(response, idAdeverinta, numePrenume, cnp, functie, departament, 
                       motiv, tipAdeverinta, salariu, dataAngajarii);
            
        } catch (Exception e) {
            System.err.println("Eroare: " + e.getMessage());
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<html><head><title>Eroare</title></head><body>");
            out.println("<h1>A aparut o eroare la generarea adeverintei</h1>");
            out.println("<p>Detalii eroare: " + e.getMessage() + "</p>");
            out.println("<p><a href='adeverinte_mele.jsp'>inapoi la adeverintele mele</a></p>");
            out.println("</body></html>");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignored */ }
            }
        }
    }
    
    private void generarePDFDirect(HttpServletResponse response, int idAdeverinta, 
                           String numePrenume, String cnp, String functie, 
                           String departament, String motiv, int tipAdeverinta, 
                           int salariu, String dataAngajarii) 
            throws IOException {
        
        try {
            // Configuram response pentru a servi un PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"adeverinta_" + idAdeverinta + ".pdf\"");
            
            // Cream documentul PDF direct in output stream-ul response-ului
            Document document = new Document(PageSize.A4);
            PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            
            // Adaugam continutul
            Font titleFont = new Font(Font.FontFamily.TIMES_ROMAN, 18, Font.BOLD);
            Font headerFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.BOLD);
            Font normalFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.NORMAL);
            
            // Titlu
            Paragraph title = new Paragraph("ADEVERINTA", titleFont);
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
                case 1: // Adeverinta de salariat
                    content.add(new Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                    content.add(new Chunk(numePrenume, headerFont));
                    content.add(new Chunk(", CNP " + cnp + ", este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                    content.add(new Chunk(functie, headerFont));
                    content.add(new Chunk(" in cadrul departamentului ", normalFont));
                    content.add(new Chunk(departament, headerFont));
                    content.add(new Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                    break;
                    
                case 2: // Adeverinta de venit
                    content.add(new Chunk("Prin prezenta, se adevereste faptul ca ", normalFont));
                    content.add(new Chunk(numePrenume, headerFont));
                    content.add(new Chunk(", CNP " + cnp + ", angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                    content.add(new Chunk(functie, headerFont));
                    content.add(new Chunk(" in cadrul departamentului ", normalFont));
                    content.add(new Chunk(departament, headerFont));
                    content.add(new Chunk(", are un salariu brut de ", normalFont));
                    content.add(new Chunk(String.format("%,d", salariu) + " RON", headerFont));
                    content.add(new Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                    break;
                    
                // Restul cazurilor (aceleasi ca anterior)
                default:
                    content.add(new Chunk("Prin prezenta, adeverim ca ", normalFont));
                    content.add(new Chunk(numePrenume, headerFont));
                    content.add(new Chunk(", CNP " + cnp + ", este angajat(a) al(a) companiei noastre, in functia de ", normalFont));
                    content.add(new Chunk(functie, headerFont));
                    content.add(new Chunk(" in cadrul departamentului ", normalFont));
                    content.add(new Chunk(departament, headerFont));
                    content.add(new Chunk(".\n\nAceasta adeverinta se elibereaza pentru a-i servi la " + motiv + ".", normalFont));
                    break;
            }
            
            document.add(content);
            document.add(Chunk.NEWLINE);
            document.add(Chunk.NEWLINE);
            
            // Data si semnatura
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
            
//            // Informatii juridice
//            Paragraph legal = new Paragraph(
//                    "Acest document a fost generat automat si nu necesita semnatura olografa conform art. 5 din Legea 455/2001.", 
//                    new Font(Font.FontFamily.TIMES_ROMAN, 8, Font.ITALIC));
//            legal.setAlignment(Element.ALIGN_CENTER);
//            document.add(legal);
            
            // Finalizare document
            document.close();
            writer.close();
            
            System.out.println("PDF generat cu succes pentru adeverinta " + idAdeverinta);
            
        } catch (Exception e) {
            System.err.println("Eroare la generarea PDF direct: " + e.getMessage());
            e.printStackTrace();
            throw new IOException("Nu s-a putut genera adeverinta PDF: " + e.getMessage(), e);
        }
    }
}