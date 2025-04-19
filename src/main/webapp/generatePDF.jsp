<%@ page contentType="application/pdf;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.fasterxml.jackson.databind.*" %>
<%@ page import="com.itextpdf.kernel.pdf.*" %>
<%@ page import="com.itextpdf.kernel.geom.PageSize" %>
<%@ page import="com.itextpdf.kernel.font.*" %>
<%@ page import="com.itextpdf.layout.*" %>
<%@ page import="com.itextpdf.layout.element.*" %>
<%@ page import="com.itextpdf.layout.property.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.util.Date" %>


<%
    BufferedReader reader = request.getReader();
    StringBuilder jsonReceived = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        jsonReceived.append(line);
    }

    ObjectMapper objectMapper = new ObjectMapper();
    Map<String, Object> jsonData = objectMapper.readValue(jsonReceived.toString(), HashMap.class);

    String header = (String) jsonData.get("header");
    List<Map<String, Object>> records = (List<Map<String, Object>>) jsonData.get("data");

    String timestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    String fileName = "raport" + timestamp + ".pdf";

    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

    PdfWriter writer = new PdfWriter(response.getOutputStream());
    PdfDocument pdf = new PdfDocument(writer);

    // 🔄 Orientare pe latime
    Document document = new Document(pdf, PageSize.A4.rotate());
    document.setMargins(20, 20, 20, 20);

    PdfFont font;
    try {
        font = PdfFontFactory.createFont("Times-Roman");
    } catch (Exception e) {
        font = PdfFontFactory.createFont();
    }

    document.add(new Paragraph(header)
        .setFont(font)
        .setFontSize(16)
        .setBold()
        .setTextAlignment(TextAlignment.CENTER));
    document.add(new Paragraph("\n"));

    if (records != null && !records.isEmpty()) {
        LinkedHashSet<String> headers = new LinkedHashSet<>(records.get(0).keySet());
        Table table = new Table(headers.size()).useAllAvailableWidth();

        for (String col : headers) {
            table.addHeaderCell(new Cell().add(new Paragraph(col)
                .setBold()
                .setFont(font)
                .setFontSize(10)
                .setTextAlignment(TextAlignment.CENTER)));
        }

        for (Map<String, Object> row : records) {
            for (String col : headers) {
                table.addCell(new Cell().add(new Paragraph(String.valueOf(row.getOrDefault(col, "—")))
                    .setFont(font)
                    .setFontSize(9)
                    .setTextAlignment(TextAlignment.CENTER)));
            }
        }

        document.add(table);
    } else {
        document.add(new Paragraph("Nu exista date disponibile!")
            .setFont(font)
            .setFontSize(12));
    }

    document.close();
%>
