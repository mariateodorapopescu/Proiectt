<%@ page contentType="application/pdf;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*, com.fasterxml.jackson.databind.*, com.itextpdf.text.*, com.itextpdf.text.pdf.*" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.LinkedHashSet" %>
<%@ page contentType="application/pdf;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%@ page import="com.itextpdf.kernel.pdf.PdfWriter" %>
<%@ page import="com.itextpdf.kernel.pdf.PdfDocument" %>
<%@ page import="com.itextpdf.kernel.geom.PageSize" %>
<%@ page import="com.itextpdf.kernel.font.PdfFont" %>
<%@ page import="com.itextpdf.kernel.font.PdfFontFactory" %>

<%@ page import="com.itextpdf.layout.Document" %>
<%@ page import="com.itextpdf.layout.element.Paragraph" %>
<%@ page import="com.itextpdf.layout.element.Table" %>
<%@ page import="com.itextpdf.layout.element.Cell" %>
<%@ page import="com.itextpdf.layout.property.TextAlignment" %>
<%@ page import="com.itextpdf.layout.property.UnitValue" %>

<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>

<%

    // Read JSON from request body
    BufferedReader reader = request.getReader();
    StringBuilder jsonReceived = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        jsonReceived.append(line);
    }

    // Convert JSON string to a Java object
    ObjectMapper objectMapper = new ObjectMapper();
    Map<String, Object> jsonData = objectMapper.readValue(jsonReceived.toString(), HashMap.class);

    // Get title from JSON
    String header = (String) jsonData.get("header");

    // Get data records
    List<Map<String, Object>> records = (List<Map<String, Object>>) jsonData.get("data");

 // 📌 Formatăm data și ora în numele fișierului
    String timestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    String fileName = "Raport_" + timestamp + ".pdf";

    System.out.println("📂 PDF generat cu numele: " + fileName); // Debugging în consolă

    // 📌 Configurăm răspunsul pentru descărcare corectă
    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
    response.setHeader("Content-Transfer-Encoding", "binary");
    response.setHeader("Expires", "0");
    response.setHeader("Cache-Control", "must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "public");

    // 📌 Creare document PDF
    PdfWriter writer = new PdfWriter(response.getOutputStream());
    PdfDocument pdf = new PdfDocument(writer);
    Document document = new Document(pdf, PageSize.A4);
    document.setMargins(28.35f, 28.35f, 28.35f, 28.35f); // 2 cm margins

    // Title
    PdfFont font;
    try {
        font = PdfFontFactory.createFont("Times-Roman"); // Default în iText 7
    } catch (Exception e) {
        font = PdfFontFactory.createFont("Arial");
    }
    document.add(new Paragraph(header).setFont(font).setFontSize(18).setBold().setTextAlignment(TextAlignment.CENTER));
     document.add(new Paragraph("\n"));

    // Create Table
    if (records != null && !records.isEmpty()) {
        LinkedHashSet<String> headers = new LinkedHashSet<>(records.get(0).keySet());
        Table table = new Table(UnitValue.createPercentArray(headers.size())).useAllAvailableWidth();

        for (String col : headers) {
        	 table.addHeaderCell(new Cell().add(new Paragraph(col)
        	            .setBold()
        	            .setFont(font)
        	            .setFontSize(12)
        	            .setTextAlignment(TextAlignment.JUSTIFIED)));
        }
        for (Map<String, Object> row : records) {
            for (String col : headers) {
            	table.addCell(new Cell().add(new Paragraph(row.getOrDefault(col, "—").toString())
                        .setFont(font)
                        .setFontSize(12)
                        .setTextAlignment(TextAlignment.JUSTIFIED)));
            }
        }
        document.add(table);
    } else {
        document.add(new Paragraph("Nu exista date disponibile!").setFont(font).setFontSize(12));
    }

    document.close();
%>
