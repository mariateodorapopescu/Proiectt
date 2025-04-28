package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import bean.MyUser;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import bean.MyUser;

public class GenerareCarteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userId = currentUser.getId();
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=carte_munca.pdf");
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Date personale
            String sql = "SELECT * FROM useri WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        Document document = new Document();
                        PdfWriter.getInstance(document, response.getOutputStream());
                        document.open();
                        
                        // Antet
                        Font headerFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
                        Paragraph header = new Paragraph("CARTE DE MUNCĂ", headerFont);
                        header.setAlignment(Element.ALIGN_CENTER);
                        document.add(header);
                        
                        document.add(new Paragraph(" "));
                        
                        // Logo firmă (dacă există)
                        // Image logo = Image.getInstance(getServletContext().getRealPath("/images/logo.png"));
                        // logo.scaleToFit(100, 100);
                        // document.add(logo);
                        
                        // Date personale
                        PdfPTable personalData = new PdfPTable(2);
                        personalData.setWidthPercentage(100);
                        
                        personalData.addCell("Nume:");
                        personalData.addCell(rs.getString("nume"));
                        personalData.addCell("Prenume:");
                        personalData.addCell(rs.getString("prenume"));
                        personalData.addCell("Data nașterii:");
                        personalData.addCell(rs.getString("data_nasterii"));
                        personalData.addCell("CNP:");
                        personalData.addCell(rs.getString("cnp"));
                        personalData.addCell("Adresa:");
                        personalData.addCell(rs.getString("adresa"));
                        personalData.addCell("Email:");
                        personalData.addCell(rs.getString("email"));
                        personalData.addCell("Telefon:");
                        personalData.addCell(rs.getString("telefon"));
                        
                        document.add(personalData);
                        document.add(new Paragraph(" "));
                        
                        // Verifică dacă există tabela istoric_pozitii
                        boolean tabelaExista = false;
                        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'istoric_pozitii'");
                             ResultSet rsCheck = checkStmt.executeQuery()) {
                            tabelaExista = rsCheck.next();
                        }
                        
                        // Adaugă istoric poziții doar dacă tabela există
                        if (tabelaExista) {
                            // Istoric poziții
                            String istoricSql = "SELECT h.*, t.denumire as pozitie, d.nume_dep " +
                                  "FROM istoric_pozitii h " +
                                  "JOIN tipuri t ON h.tip_nou = t.tip " +
                                  "JOIN departament d ON h.id_dep_nou = d.id_dep " +
                                  "WHERE h.id_ang = ? " +
                                  "ORDER BY h.data_schimbare ASC";
                            try (PreparedStatement istoricStmt = conn.prepareStatement(istoricSql)) {
                                istoricStmt.setInt(1, userId);
                                try (ResultSet rsIstoric = istoricStmt.executeQuery()) {
                                    PdfPTable istoricTable = new PdfPTable(4);
                                    istoricTable.setWidthPercentage(100);
                                    istoricTable.setWidths(new float[]{3, 3, 3, 3});
                                    
                                    // Antet tabel
                                    istoricTable.addCell("Începând de la");
                                    istoricTable.addCell("Denumire");
                                    istoricTable.addCell("Companie");
                                    istoricTable.addCell("Departament");
                                    
                                    boolean hasRows = false;
                                    while (rsIstoric.next()) {
                                        hasRows = true;
                                        istoricTable.addCell(rsIstoric.getDate("data_schimbare").toString());
                                        istoricTable.addCell(rsIstoric.getString("pozitie"));
                                        istoricTable.addCell("Compania X SRL"); // Poate fi parametrizat
                                        istoricTable.addCell(rsIstoric.getString("nume_dep"));
                                    }
                                    
                                    // Adaugă tabela doar dacă există date de istoric
                                    if (hasRows) {
                                        document.add(new Paragraph("ISTORIC ANGAJARE", headerFont));
                                        document.add(new Paragraph(" "));
                                        document.add(istoricTable);
                                    } else {
                                        document.add(new Paragraph("ISTORIC ANGAJARE", headerFont));
                                        document.add(new Paragraph(" "));
                                        document.add(new Paragraph("Nu există informații despre istoricul de angajare."));
                                    }
                                }
                            }
                        } else {
                            // Adaugă pozitia curenta a angajatului daca nu exista tabela de istoric
                            String pozitieSQL = "SELECT t.denumire as pozitie, d.nume_dep " +
                                               "FROM useri u " +
                                               "JOIN tipuri t ON u.tip = t.tip " +
                                               "JOIN departament d ON u.id_dep = d.id_dep " +
                                               "WHERE u.id = ?";
                            try (PreparedStatement pozitieStmt = conn.prepareStatement(pozitieSQL)) {
                                pozitieStmt.setInt(1, userId);
                                try (ResultSet rsPozitie = pozitieStmt.executeQuery()) {
                                    if (rsPozitie.next()) {
                                        document.add(new Paragraph("POZIȚIE CURENTĂ", headerFont));
                                        document.add(new Paragraph(" "));
                                        
                                        PdfPTable pozitieTable = new PdfPTable(2);
                                        pozitieTable.setWidthPercentage(100);
                                        
                                        pozitieTable.addCell("Denumire funcție:");
                                        pozitieTable.addCell(rsPozitie.getString("pozitie"));
                                        pozitieTable.addCell("Departament:");
                                        pozitieTable.addCell(rsPozitie.getString("nume_dep"));
                                        
                                        document.add(pozitieTable);
                                    }
                                }
                            }
                        }
                        
                        // Adaugă experiență si studii dacă există tabela
                        boolean existaExperienta = false;
                        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'experienta'");
                             ResultSet rsCheck = checkStmt.executeQuery()) {
                            existaExperienta = rsCheck.next();
                        }
                        
                        if (existaExperienta) {
                            String expSql = "SELECT e.*, t.denumire as pozitie, d.nume_dep " +
                                           "FROM experienta e " +
                                           "LEFT JOIN tipuri t ON e.tip = t.tip " +
                                           "LEFT JOIN departament d ON e.id_dep = d.id_dep " +
                                           "WHERE e.id_ang = ? " +
                                           "ORDER BY e.start DESC";
                            try (PreparedStatement expStmt = conn.prepareStatement(expSql)) {
                                expStmt.setInt(1, userId);
                                try (ResultSet rsExp = expStmt.executeQuery()) {
                                    if (rsExp.next()) {
                                        document.add(new Paragraph(" "));
                                        document.add(new Paragraph("EXPERIENȚĂ ANTERIOARĂ", headerFont));
                                        document.add(new Paragraph(" "));
                                        
                                        PdfPTable expTable = new PdfPTable(4);
                                        expTable.setWidthPercentage(100);
                                        expTable.setWidths(new float[]{3, 3, 2, 4});
                                        
                                        expTable.addCell("Perioada");
                                        expTable.addCell("Funcție");
                                        expTable.addCell("Instituție");
                                        expTable.addCell("Descriere");
                                        
                                        do {
                                            String perioada = rsExp.getDate("start") + " - " + 
                                                             (rsExp.getDate("end") != null ? rsExp.getDate("end") : "Prezent");
                                            expTable.addCell(perioada);
                                            expTable.addCell(rsExp.getString("pozitie") != null ? rsExp.getString("pozitie") : rsExp.getString("den_job"));
                                            expTable.addCell(rsExp.getString("instit"));
                                            expTable.addCell(rsExp.getString("descriere"));
                                        } while (rsExp.next());
                                        
                                        document.add(expTable);
                                    }
                                }
                            }
                        }
                        
                        boolean existaStudii = false;
                        try (PreparedStatement checkStmt = conn.prepareStatement("SHOW TABLES LIKE 'studii'");
                             ResultSet rsCheck = checkStmt.executeQuery()) {
                            existaStudii = rsCheck.next();
                        }
                        
                        if (existaStudii) {
                            String studiiSql = "SELECT s.*, c.semnificatie as nivel_studii " +
                                              "FROM studii s " +
                                              "JOIN cicluri c ON s.ciclu = c.id " +
                                              "WHERE s.id_ang = ? " +
                                              "ORDER BY s.start DESC";
                            try (PreparedStatement studiiStmt = conn.prepareStatement(studiiSql)) {
                                studiiStmt.setInt(1, userId);
                                try (ResultSet rsStudii = studiiStmt.executeQuery()) {
                                    if (rsStudii.next()) {
                                        document.add(new Paragraph(" "));
                                        document.add(new Paragraph("STUDII", headerFont));
                                        document.add(new Paragraph(" "));
                                        
                                        PdfPTable studiiTable = new PdfPTable(4);
                                        studiiTable.setWidthPercentage(100);
                                        studiiTable.setWidths(new float[]{3, 3, 2, 3});
                                        
                                        studiiTable.addCell("Perioada");
                                        studiiTable.addCell("Instituție");
                                        studiiTable.addCell("Nivel");
                                        studiiTable.addCell("Facultate/Specializare");
                                        
                                        do {
                                            String perioada = rsStudii.getDate("start") + " - " + 
                                                             (rsStudii.getDate("end") != null ? rsStudii.getDate("end") : "Prezent");
                                            studiiTable.addCell(perioada);
                                            studiiTable.addCell(rsStudii.getString("universitate"));
                                            studiiTable.addCell(rsStudii.getString("nivel_studii"));
                                            studiiTable.addCell(rsStudii.getString("facultate"));
                                        } while (rsStudii.next());
                                        
                                        document.add(studiiTable);
                                    }
                                }
                            }
                        }
                        
                        // Footer
                        document.add(new Paragraph(" "));
                        document.add(new Paragraph(" "));
                        Font footerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC);
                        Paragraph footer = new Paragraph("Document generat la data: " + new java.util.Date(), footerFont);
                        footer.setAlignment(Element.ALIGN_CENTER);
                        document.add(footer);
                        
                        document.close();
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Nu s-au găsit datele utilizatorului");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException | DocumentException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Eroare la generarea cărții de muncă: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}