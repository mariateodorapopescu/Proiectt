<%@ page contentType="application/pdf;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.fasterxml.jackson.databind.*" %>
<%@ page import="com.itextpdf.kernel.pdf.*" %>
<%@ page import="com.itextpdf.kernel.geom.PageSize" %>
<%@ page import="com.itextpdf.kernel.font.*" %>
<%@ page import="com.itextpdf.layout.*" %>
<%@ page import="com.itextpdf.layout.element.*" %>
<%@ page import="com.itextpdf.layout.property.*" %>
<%@ page import="com.itextpdf.layout.borders.*" %>
<%@ page import="com.itextpdf.kernel.colors.ColorConstants" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    // Citeste JSON-ul trimis
    BufferedReader reader = request.getReader();
    StringBuilder jsonReceived = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        jsonReceived.append(line);
    }

    ObjectMapper objectMapper = new ObjectMapper();
    Map<String, Object> jsonData = objectMapper.readValue(jsonReceived.toString(), HashMap.class);

    // Formator pentru valori numerice
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("ro", "RO"));

    // Extragem datele din JSON
    String numeCompanie = (String) jsonData.getOrDefault("companie", "");
    String luna = (String) jsonData.getOrDefault("luna", "");
    String numeAngajat = (String) jsonData.getOrDefault("nume", "");
    String cnp = (String) jsonData.getOrDefault("cnp", "");
    String functie = (String) jsonData.getOrDefault("functie", "");
    String departament = (String) jsonData.getOrDefault("departament", "");
    
    // Date financiare
    double salariuBaza = ((Number) jsonData.getOrDefault("salariu_baza", 0)).doubleValue();
    double valoareSpor = ((Number) jsonData.getOrDefault("valoare_spor", 0)).doubleValue();
    String numeSpor = (String) jsonData.getOrDefault("nume_spor", "");
    double procentSpor = ((Number) jsonData.getOrDefault("procent_spor", 0)).doubleValue();
    double valoarePenalizare = ((Number) jsonData.getOrDefault("valoare_penalizare", 0)).doubleValue();
    String numePenalizare = (String) jsonData.getOrDefault("nume_penalizare", "");
    double procentPenalizare = ((Number) jsonData.getOrDefault("procent_penalizare", 0)).doubleValue();
    
    // Ore suplimentare si alte venituri
    int oreSuplimentare = ((Number) jsonData.getOrDefault("ore_suplimentare", 0)).intValue();
    double valoareOreSuplimentare = ((Number) jsonData.getOrDefault("valoare_ore_suplimentare", 0)).doubleValue();
    int zileLucrate = ((Number) jsonData.getOrDefault("zile_lucrate", 0)).intValue();
    int zileAbsente = ((Number) jsonData.getOrDefault("zile_absente", 0)).intValue();
    
    // Valori calculate
    double salariuBrut = ((Number) jsonData.getOrDefault("salariu_brut", 0)).doubleValue();
    double cas = ((Number) jsonData.getOrDefault("cas", 0)).doubleValue();
    double cass = ((Number) jsonData.getOrDefault("cass", 0)).doubleValue();
    double impozit = ((Number) jsonData.getOrDefault("impozit", 0)).doubleValue();
    double salariuNet = ((Number) jsonData.getOrDefault("salariu_net", 0)).doubleValue();

    // Generare nume fisier
    String timestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    String fileName = "fluturas_" + numeAngajat.replaceAll("\\s+", "_") + "_" + timestamp + ".pdf";

    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

    PdfWriter writer = new PdfWriter(response.getOutputStream());
    PdfDocument pdf = new PdfDocument(writer);
    Document document = new Document(pdf, PageSize.A4);
    document.setMargins(20, 20, 20, 20);

    PdfFont font;
    try {
        font = PdfFontFactory.createFont("Times-Roman");
    } catch (Exception e) {
        font = PdfFontFactory.createFont();
    }

    // Adauga titlul documentului
    document.add(new Paragraph("FLUTURAS DE SALARIU")
        .setFont(font)
        .setFontSize(16)
        .setBold()
        .setTextAlignment(TextAlignment.CENTER));
    
    document.add(new Paragraph(luna)
        .setFont(font)
        .setFontSize(14)
        .setTextAlignment(TextAlignment.CENTER)
        .setMarginBottom(20));

    // Tabel informatii angajat
    Table infoTable = new Table(2)
        .setWidth(UnitValue.createPercentValue(100))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1));
    
    infoTable.addCell(new Cell().add(new Paragraph("Companie").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    infoTable.addCell(new Cell().add(new Paragraph(numeCompanie).setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    infoTable.addCell(new Cell().add(new Paragraph("Nume si prenume").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    infoTable.addCell(new Cell().add(new Paragraph(numeAngajat).setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    infoTable.addCell(new Cell().add(new Paragraph("CNP").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    infoTable.addCell(new Cell().add(new Paragraph(cnp).setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    infoTable.addCell(new Cell().add(new Paragraph("Functie").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    infoTable.addCell(new Cell().add(new Paragraph(functie).setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    infoTable.addCell(new Cell().add(new Paragraph("Departament").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    infoTable.addCell(new Cell().add(new Paragraph(departament).setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    document.add(infoTable);
    document.add(new Paragraph("\n"));
    
    // Tabel zile lucrate
    Table zileTable = new Table(3)
        .setWidth(UnitValue.createPercentValue(100))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1));
    
    zileTable.addCell(new Cell(1, 3).add(new Paragraph("Pontaj").setFont(font).setFontSize(11).setBold())
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    zileTable.addCell(new Cell().add(new Paragraph("Zile lucratoare in luna").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph(String.valueOf(zileLucrate + zileAbsente)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    zileTable.addCell(new Cell().add(new Paragraph("Zile lucrate").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph(String.valueOf(zileLucrate)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    zileTable.addCell(new Cell().add(new Paragraph("Zile absente").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph(String.valueOf(zileAbsente)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    zileTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    document.add(zileTable);
    document.add(new Paragraph("\n"));
    
    // Tabel venituri
    Table venituriTable = new Table(3)
        .setWidth(UnitValue.createPercentValue(100))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1));
    
    venituriTable.addCell(new Cell(1, 3).add(new Paragraph("Venituri").setFont(font).setFontSize(11).setBold())
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    venituriTable.addCell(new Cell().add(new Paragraph("Descriere").setFont(font).setFontSize(10).setBold())
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph("Cantitate").setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph("Valoare (RON)").setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    venituriTable.addCell(new Cell().add(new Paragraph("Salariu de baza").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", salariuBaza)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    // Adauga sporul daca exista
    if (valoareSpor > 0) {
        venituriTable.addCell(new Cell().add(new Paragraph(numeSpor + " (" + procentSpor + "%)").setFont(font).setFontSize(10))
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.CENTER)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", valoareSpor)).setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.RIGHT)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    }
    
    // Adauga ore suplimentare daca exista
    if (oreSuplimentare > 0) {
        venituriTable.addCell(new Cell().add(new Paragraph("Ore suplimentare").setFont(font).setFontSize(10))
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph(String.valueOf(oreSuplimentare)).setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.CENTER)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", valoareOreSuplimentare)).setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.RIGHT)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    }
    
    // Adauga penalizari daca exista
    if (valoarePenalizare > 0) {
        venituriTable.addCell(new Cell().add(new Paragraph(numePenalizare + " (" + procentPenalizare + "%)").setFont(font).setFontSize(10))
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.CENTER)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
        venituriTable.addCell(new Cell().add(new Paragraph("-" + String.format("%.0f", valoarePenalizare)).setFont(font).setFontSize(10))
            .setTextAlignment(TextAlignment.RIGHT)
            .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    }
    
    // Total venit brut
    venituriTable.addCell(new Cell().add(new Paragraph("TOTAL VENIT BRUT").setFont(font).setFontSize(10).setBold())
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    venituriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", salariuBrut)).setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    document.add(venituriTable);
    document.add(new Paragraph("\n"));
    
    // Tabel deduceri
    Table deduceriTable = new Table(3)
        .setWidth(UnitValue.createPercentValue(100))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1));
    
    deduceriTable.addCell(new Cell(1, 3).add(new Paragraph("Contributii si impozite").setFont(font).setFontSize(11).setBold())
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    deduceriTable.addCell(new Cell().add(new Paragraph("Descriere").setFont(font).setFontSize(10).setBold())
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("Procent (%)").setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("Valoare (RON)").setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    deduceriTable.addCell(new Cell().add(new Paragraph("CAS").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("25%").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", cas)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    deduceriTable.addCell(new Cell().add(new Paragraph("CASS").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("10%").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", cass)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    deduceriTable.addCell(new Cell().add(new Paragraph("Impozit pe venit").setFont(font).setFontSize(10))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("10%").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", impozit)).setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    // Total deduceri
    double totalDeduceri = cas + cass + impozit;
    deduceriTable.addCell(new Cell().add(new Paragraph("TOTAL CONTRIBUTII").setFont(font).setFontSize(10).setBold())
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    deduceriTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", totalDeduceri)).setFont(font).setFontSize(10).setBold())
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    document.add(deduceriTable);
    document.add(new Paragraph("\n"));
    
    // Tabel salariu net
    Table netTable = new Table(3)
        .setWidth(UnitValue.createPercentValue(100))
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1));
    
    netTable.addCell(new Cell().add(new Paragraph("SALARIU NET").setFont(font).setFontSize(11).setBold())
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    netTable.addCell(new Cell().add(new Paragraph("").setFont(font).setFontSize(10))
        .setTextAlignment(TextAlignment.CENTER)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    netTable.addCell(new Cell().add(new Paragraph(String.format("%.0f", salariuNet)).setFont(font).setFontSize(11).setBold())
        .setTextAlignment(TextAlignment.RIGHT)
        .setBorder(new SolidBorder(ColorConstants.BLACK, 1)));
    
    document.add(netTable);
    
    // Subsol
    document.add(new Paragraph("\n"));
    document.add(new Paragraph("Document generat automat. Nu necesita semnatura.").setFont(font).setFontSize(8).setItalic()
        .setTextAlignment(TextAlignment.CENTER));
    
    document.close();
%>