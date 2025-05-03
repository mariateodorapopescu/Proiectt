package Servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

public class ReportExportServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1) Verificare sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String exportType = request.getParameter("export");
        String reportType = request.getParameter("type");

        // 2) Încărcare driver JDBC și deschidere conexiune
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("Driver JDBC neidentificat!", e);
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            if ("pdf".equalsIgnoreCase(exportType)) {
                exportToPDF(request, response, reportType, conn);
            } else if ("excel".equalsIgnoreCase(exportType)) {
                exportToExcel(request, response, reportType, conn);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tip de export necunoscut");
            }
        } catch (SQLException e) {
            throw new ServletException("Eroare la conectarea cu BD: " + e.getMessage(), e);
        }
    }

    private void exportToPDF(HttpServletRequest request, HttpServletResponse response,
                             String reportType, Connection conn)
            throws IOException {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=" + reportType + "_report.pdf");

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Titlu
            com.itextpdf.text.Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            Paragraph title = new Paragraph("Raport " + reportType.toUpperCase(), titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            // Data generării
            com.itextpdf.text.Font dateFont = FontFactory.getFont(FontFactory.HELVETICA, 12);
            document.add(new Paragraph("Generat la: " + new java.util.Date(), dateFont));
            document.add(Chunk.NEWLINE);

            // Conținut specific
            switch (reportType) {
                case "recruitment":
                    addRecruitmentReportContent(document, conn);
                    break;
                case "leave":
                    addLeaveReportContent(document, conn);
                    break;
                case "employee":
                    addEmployeeReportContent(document, conn);
                    break;
                case "department":
                    addDepartmentReportContent(document, conn);
                    break;
                default:
                    document.add(new Paragraph("Tip de raport necunoscut."));
            }

            document.close();
        } catch (DocumentException | SQLException e) {
            throw new IOException("Eroare la generarea PDF-ului: " + e.getMessage(), e);
        }
    }

    private void exportToExcel(HttpServletRequest request, HttpServletResponse response,
            String reportType, Connection conn)
throws IOException {
response.setContentType(
"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
response.setHeader("Content-Disposition",
"attachment; filename=" + reportType + "_report.xlsx");

XSSFWorkbook workbook = new XSSFWorkbook();
try {
XSSFSheet sheet = workbook.createSheet(reportType + " Report");

switch (reportType) {
case "recruitment":
 createRecruitmentExcelReport(workbook, sheet, conn);
 break;
case "leave":
 createLeaveExcelReport(workbook, sheet, conn);
 break;
case "employee":
 createEmployeeExcelReport(workbook, sheet, conn);
 break;
case "department":
 createDepartmentExcelReport(workbook, sheet, conn);
 break;
default:
 // sheet empty
}

workbook.write(response.getOutputStream());
} catch (SQLException e) {
throw new IOException("Eroare la generarea Excel-ului: " + e.getMessage(), e);
} finally {
// Închide manual workbook-ul
try {
	((Connection) workbook).close();
} catch (SQLException e) {
	// TODO Auto-generated catch block
	e.printStackTrace();
}
}
}
    private void createRecruitmentExcelReport(XSSFWorkbook workbook, XSSFSheet sheet, Connection conn) 
            throws SQLException {
        // Configurăm headerul
        Row header = sheet.createRow(0);
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBoldweight((short)0);
        headerStyle.setFont(headerFont);
        
        header.createCell(0).setCellValue("Lună");
        header.getCell(0).setCellStyle(headerStyle);
        header.createCell(1).setCellValue("Număr aplicații");
        header.getCell(1).setCellStyle(headerStyle);
        header.createCell(2).setCellValue("Departament");
        header.getCell(2).setCellStyle(headerStyle);
        header.createCell(3).setCellValue("Poziție");
        header.getCell(3).setCellStyle(headerStyle);
        
        // Configurăm autosize pentru coloane
        sheet.setColumnWidth(0, 3000);
        sheet.setColumnWidth(1, 4000);
        sheet.setColumnWidth(2, 6000);
        sheet.setColumnWidth(3, 5000);
        
        String sql = "SELECT MONTH(a.data_apl) AS luna, COUNT(*) AS cnt, d.nume_dep, t.denumire " +
                     "FROM aplicari a " +
                     "JOIN joburi j ON a.job_id = j.id " +
                     "JOIN departament d ON j.departament = d.id_dep " +
                     "JOIN tipuri t ON j.pozitie = t.tip " +
                     "GROUP BY MONTH(a.data_apl), d.nume_dep, t.denumire " +
                     "ORDER BY luna, d.nume_dep";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int rowNum = 1;
            while (rs.next()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rs.getInt("luna"));
                row.createCell(1).setCellValue(rs.getInt("cnt"));
                row.createCell(2).setCellValue(rs.getString("nume_dep"));
                row.createCell(3).setCellValue(rs.getString("denumire"));
            }
        }
    }

    private void createLeaveExcelReport(XSSFWorkbook workbook, XSSFSheet sheet, Connection conn) 
            throws SQLException {
        // Configurăm headerul
        Row header = sheet.createRow(0);
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBoldweight((short)0);
        headerStyle.setFont(headerFont);
        
        header.createCell(0).setCellValue("Angajat");
        header.getCell(0).setCellStyle(headerStyle);
        header.createCell(1).setCellValue("Total zile");
        header.getCell(1).setCellStyle(headerStyle);
        header.createCell(2).setCellValue("Număr concedii");
        header.getCell(2).setCellStyle(headerStyle);
        header.createCell(3).setCellValue("Departament");
        header.getCell(3).setCellStyle(headerStyle);
        header.createCell(4).setCellValue("Tip concediu predominant");
        header.getCell(4).setCellStyle(headerStyle);
        
        // Configurăm autosize pentru coloane
        for (int i = 0; i < 5; i++) {
            sheet.setColumnWidth(i, 4500);
        }
        
        String sql = "SELECT CONCAT(u.nume,' ',u.prenume) AS ang, " +
                     "SUM(DATEDIFF(c.end_c, c.start_c) + 1) AS zile, " +
                     "COUNT(*) AS cnt, " +
                     "d.nume_dep, " +
                     "(SELECT tc.motiv FROM concedii c2 " +
                     " JOIN tipcon tc ON c2.tip = tc.tip " +
                     " WHERE c2.id_ang = u.id " +
                     " GROUP BY c2.tip " +
                     " ORDER BY COUNT(*) DESC " +
                     " LIMIT 1) AS tip_predominant " +
                     "FROM concedii c " +
                     "JOIN useri u ON c.id_ang = u.id " +
                     "JOIN departament d ON u.id_dep = d.id_dep " +
                     "GROUP BY u.id, d.nume_dep " +
                     "ORDER BY zile DESC";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int rowNum = 1;
            while (rs.next()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rs.getString("ang"));
                row.createCell(1).setCellValue(rs.getInt("zile"));
                row.createCell(2).setCellValue(rs.getInt("cnt"));
                row.createCell(3).setCellValue(rs.getString("nume_dep"));
                row.createCell(4).setCellValue(rs.getString("tip_predominant"));
            }
        }
    }

    private void createEmployeeExcelReport(XSSFWorkbook workbook, XSSFSheet sheet, Connection conn) 
            throws SQLException {
        // Configurăm headerul
        Row header = sheet.createRow(0);
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBoldweight((short)0);
        headerStyle.setFont(headerFont);
        
        header.createCell(0).setCellValue("ID");
        header.getCell(0).setCellStyle(headerStyle);
        header.createCell(1).setCellValue("Nume");
        header.getCell(1).setCellStyle(headerStyle);
        header.createCell(2).setCellValue("Prenume");
        header.getCell(2).setCellStyle(headerStyle);
        header.createCell(3).setCellValue("Email");
        header.getCell(3).setCellStyle(headerStyle);
        header.createCell(4).setCellValue("Telefon");
        header.getCell(4).setCellStyle(headerStyle);
        header.createCell(5).setCellValue("Departament");
        header.getCell(5).setCellStyle(headerStyle);
        header.createCell(6).setCellValue("Poziție");
        header.getCell(6).setCellStyle(headerStyle);
        header.createCell(7).setCellValue("Data angajării");
        header.getCell(7).setCellStyle(headerStyle);
        
        // Configurăm autosize pentru coloane
        for (int i = 0; i < 8; i++) {
            sheet.setColumnWidth(i, 3500 + (i * 500));
        }
        
        String sql = "SELECT u.id, u.nume, u.prenume, u.email, u.telefon, d.nume_dep, " +
                     "t.denumire, u.data_ang " +
                     "FROM useri u " +
                     "JOIN departament d ON u.id_dep = d.id_dep " +
                     "JOIN tipuri t ON u.tip = t.tip " +
                     "WHERE u.activ = 1 " +
                     "ORDER BY d.nume_dep, u.nume";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int rowNum = 1;
            
            CellStyle dateStyle = workbook.createCellStyle();
            CreationHelper createHelper = workbook.getCreationHelper();
            dateStyle.setDataFormat(createHelper.createDataFormat().getFormat("dd.MM.yyyy"));
            
            while (rs.next()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rs.getInt("id"));
                row.createCell(1).setCellValue(rs.getString("nume"));
                row.createCell(2).setCellValue(rs.getString("prenume"));
                row.createCell(3).setCellValue(rs.getString("email"));
                row.createCell(4).setCellValue(rs.getString("telefon"));
                row.createCell(5).setCellValue(rs.getString("nume_dep"));
                row.createCell(6).setCellValue(rs.getString("denumire"));
                
                Cell dateCell = row.createCell(7);
                if (rs.getDate("data_ang") != null) {
                    dateCell.setCellValue(rs.getDate("data_ang"));
                    dateCell.setCellStyle(dateStyle);
                }
            }
        }
    }

    private void createDepartmentExcelReport(XSSFWorkbook workbook, XSSFSheet sheet, Connection conn) 
            throws SQLException {
        // Configurăm headerul
        Row header = sheet.createRow(0);
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBoldweight((short) 0);
        headerStyle.setFont(headerFont);
        
        header.createCell(0).setCellValue("Departament");
        header.getCell(0).setCellStyle(headerStyle);
        header.createCell(1).setCellValue("Număr angajați");
        header.getCell(1).setCellStyle(headerStyle);
        header.createCell(2).setCellValue("Salariu mediu");
        header.getCell(2).setCellStyle(headerStyle);
        header.createCell(3).setCellValue("Vechime medie (zile)");
        header.getCell(3).setCellStyle(headerStyle);
        header.createCell(4).setCellValue("Manager");
        header.getCell(4).setCellStyle(headerStyle);
        
        // Configurăm autosize pentru coloane
        for (int i = 0; i < 5; i++) {
            sheet.setColumnWidth(i, 4000 + (i * 300));
        }
        
        String sql = "SELECT d.id_dep, d.nume_dep, COUNT(*) AS cnt, " +
                     "AVG(u.salariu_brut) AS salariu_mediu, " +
                     "AVG(DATEDIFF(CURDATE(), u.data_ang)) AS vechime_medie, " +
                     "(SELECT CONCAT(u2.nume, ' ', u2.prenume) FROM useri u2 " +
                     " WHERE u2.id_dep = d.id_dep AND u2.tip IN (0, 3, 4, 10) " + 
                     " ORDER BY u2.tip LIMIT 1) AS manager " +
                     "FROM departament d " +
                     "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                     "WHERE u.activ = 1 " +
                     "GROUP BY d.id_dep, d.nume_dep " +
                     "ORDER BY cnt DESC";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int rowNum = 1;
            
            // Stil pentru formatarea valorilor monetare
            CellStyle currencyStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            currencyStyle.setDataFormat(format.getFormat("#,##0.00 RON"));
            
            while (rs.next()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rs.getString("nume_dep"));
                row.createCell(1).setCellValue(rs.getInt("cnt"));
                
                Cell salariuCell = row.createCell(2);
                salariuCell.setCellValue(rs.getDouble("salariu_mediu"));
                salariuCell.setCellStyle(currencyStyle);
                
                row.createCell(3).setCellValue(rs.getDouble("vechime_medie"));
                row.createCell(4).setCellValue(rs.getString("manager"));
            }
        }
    }


	// ==== PDF Content Methods ====

    private void addDepartmentReportContent(Document doc, Connection conn)
            throws SQLException, DocumentException {
        // Exemplu: tabel cu număr angajați pe departament
        PdfPTable table = new PdfPTable(2);
        table.addCell("Departament");
        table.addCell("Număr angajați");

        String sql = "SELECT d.nume_dep, COUNT(*) AS cnt " +
                     "FROM useri u JOIN departament d ON u.id_dep = d.id_dep " +
                     "GROUP BY d.nume_dep";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                table.addCell(rs.getString("nume_dep"));
                table.addCell(String.valueOf(rs.getInt("cnt")));
            }
        }
        doc.add(table);
    }

    private void addEmployeeReportContent(Document doc, Connection conn)
            throws SQLException, DocumentException {
        // Exemplu: listă angajați activi
        Paragraph p = new Paragraph("Listă angajați activi:");
        doc.add(p);
        PdfPTable table = new PdfPTable(3);
        table.addCell("ID");
        table.addCell("Nume");
        table.addCell("Departament");

        String sql = "SELECT u.id, u.nume, d.nume_dep " +
                     "FROM useri u JOIN departament d ON u.id_dep = d.id_dep " +
                     "WHERE u.activ = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                table.addCell(String.valueOf(rs.getInt("id")));
                table.addCell(rs.getString("nume"));
                table.addCell(rs.getString("nume_dep"));
            }
        }
        doc.add(table);
    }

    private void addLeaveReportContent(Document doc, Connection conn)
            throws SQLException, DocumentException {
        // Exemplu: zile de concediu per angajat
        Paragraph p = new Paragraph("Zile concediu per angajat:");
        doc.add(p);
        PdfPTable table = new PdfPTable(3);
        table.addCell("Angajat");
        table.addCell("Total zile");
        table.addCell("Număr concedii");

        String sql = "SELECT CONCAT(u.nume,' ',u.prenume) AS ang, " +
                     "SUM(DATEDIFF(c.end_c, c.start_c)) AS zile, COUNT(*) AS cnt " +
                     "FROM concedii c JOIN useri u ON c.id_ang = u.id " +
                     "GROUP BY u.id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                table.addCell(rs.getString("ang"));
                table.addCell(String.valueOf(rs.getInt("zile")));
                table.addCell(String.valueOf(rs.getInt("cnt")));
            }
        }
        doc.add(table);
    }

    private void addRecruitmentReportContent(Document doc, Connection conn)
            throws SQLException, DocumentException {
        // Exemplu: aplicații lunare
        Paragraph p = new Paragraph("Număr aplicații pe luni:");
        doc.add(p);
        PdfPTable table = new PdfPTable(2);
        table.addCell("Lună");
        table.addCell("Număr aplicații");

        String sql = "SELECT MONTH(a.data_apl) AS luna, COUNT(*) AS cnt " +
                     "FROM aplicari a GROUP BY MONTH(a.data_apl)";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                table.addCell(String.valueOf(rs.getInt("luna")));
                table.addCell(String.valueOf(rs.getInt("cnt")));
            }
        }
        doc.add(table);
    }

    // ==== Excel Content Methods ====

    private void createDepartmentExcelReport(Workbook wb, Sheet sheet, Connection conn)
            throws SQLException {
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Departament");
        header.createCell(1).setCellValue("Număr angajați");

        String sql = "SELECT d.nume_dep, COUNT(*) AS cnt " +
                     "FROM useri u JOIN departament d ON u.id_dep = d.id_dep " +
                     "GROUP BY d.nume_dep";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int r = 1;
            while (rs.next()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(rs.getString("nume_dep"));
                row.createCell(1).setCellValue(rs.getInt("cnt"));
            }
        }
    }

    private void createEmployeeExcelReport(Workbook wb, Sheet sheet, Connection conn)
            throws SQLException {
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("ID");
        header.createCell(1).setCellValue("Nume");
        header.createCell(2).setCellValue("Departament");

        String sql = "SELECT u.id, u.nume, d.nume_dep " +
                     "FROM useri u JOIN departament d ON u.id_dep = d.id_dep " +
                     "WHERE u.activ = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int r = 1;
            while (rs.next()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(rs.getInt("id"));
                row.createCell(1).setCellValue(rs.getString("nume"));
                row.createCell(2).setCellValue(rs.getString("nume_dep"));
            }
        }
    }

    private void createLeaveExcelReport(Workbook wb, Sheet sheet, Connection conn)
            throws SQLException {
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Angajat");
        header.createCell(1).setCellValue("Total zile");
        header.createCell(2).setCellValue("Număr concedii");

        String sql = "SELECT CONCAT(u.nume,' ',u.prenume) AS ang, " +
                     "SUM(DATEDIFF(c.end_c, c.start_c)) AS zile, COUNT(*) AS cnt " +
                     "FROM concedii c JOIN useri u ON c.id_ang = u.id " +
                     "GROUP BY u.id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int r = 1;
            while (rs.next()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(rs.getString("ang"));
                row.createCell(1).setCellValue(rs.getInt("zile"));
                row.createCell(2).setCellValue(rs.getInt("cnt"));
            }
        }
    }

    private void createRecruitmentExcelReport(Workbook wb, Sheet sheet, Connection conn)
            throws SQLException {
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Lună");
        header.createCell(1).setCellValue("Număr aplicații");

        String sql = "SELECT MONTH(a.data_apl) AS luna, COUNT(*) AS cnt " +
                     "FROM aplicari a GROUP BY MONTH(a.data_apl)";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int r = 1;
            while (rs.next()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(rs.getInt("luna"));
                row.createCell(1).setCellValue(rs.getInt("cnt"));
            }
        }
    }
}