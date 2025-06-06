<%@ page contentType="application/pdf" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="com.itextpdf.text.*" %>
<%@ page import="com.itextpdf.text.pdf.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String reportType = request.getParameter("reportType");
            String userIdParam = request.getParameter("userId");
            
            if (reportType == null) reportType = "lunar";
            if (userIdParam == null) userIdParam = "1";
            
            int userId = Integer.parseInt(userIdParam);
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                
                // Seteaza header-ul pentru descarcare PDF
                String fileName = "Raport_" + reportType + "_" + new SimpleDateFormat("yyyy_MM_dd").format(new java.util.Date()) + ".pdf";
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                response.setContentType("application/pdf");
                
                // Initializeaza documentul PDF cu margini de 2cm (56.69 points = 2cm)
                float margin = 56.69f; // 2cm in points
                Document document = new Document(PageSize.A4, margin, margin, margin, margin);
                PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
                
                document.open();
                
                // Fonturi Times New Roman 12pt cu line height 1.5
                Font titleFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 16, Font.BOLD, BaseColor.BLACK);
                Font headerFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 14, Font.BOLD, BaseColor.BLACK);
                Font normalFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 12, Font.NORMAL, BaseColor.BLACK);
                Font smallFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 10, Font.NORMAL, BaseColor.GRAY);
                
                // Set line spacing pentru paragrafe (1.5)
                float lineSpacing = 1.5f;
                
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    
                    // Query pentru datele utilizatorului
                    String userQuery = "SELECT u.*, t.denumire AS functie, d.nume_dep, t.salariu " +
                                      "FROM useri u " +
                                      "JOIN tipuri t ON u.tip = t.tip " +
                                      "JOIN departament d ON u.id_dep = d.id_dep " +
                                      "WHERE u.id = ?";
                    
                    PreparedStatement userStmt = connection.prepareStatement(userQuery);
                    userStmt.setInt(1, userId);
                    ResultSet userRs = userStmt.executeQuery();
                    
                    if (userRs.next()) {
                        String nume = userRs.getString("nume");
                        String prenume = userRs.getString("prenume");
                        String functie = userRs.getString("functie");
                        String departament = userRs.getString("nume_dep");
                        String email = userRs.getString("email");
                        String telefon = userRs.getString("telefon");
                        java.sql.Date dataAng = userRs.getDate("data_ang");
                        int conluate = userRs.getInt("conluate");
                        int zilecons = userRs.getInt("zilecons");
                        int zileramase = userRs.getInt("zileramase");
                        double salariu = userRs.getDouble("salariu");
                        
                        // Header document
                        Paragraph title = new Paragraph("RAPORT ACTIVITATE ANGAJAT", titleFont);
                        title.setAlignment(Element.ALIGN_CENTER);
                        title.setSpacingAfter(10);
                        document.add(title);
                        
                        Paragraph subtitle = new Paragraph("Raport " + reportType.toUpperCase(), headerFont);
                        subtitle.setAlignment(Element.ALIGN_CENTER);
                        subtitle.setSpacingAfter(20);
                        document.add(subtitle);
                        
                        // Informatii personale
                        document.add(new Paragraph("INFORMATII PERSONALE", headerFont));
                        document.add(Chunk.NEWLINE);
                        
                        PdfPTable personalTable = new PdfPTable(2);
                        personalTable.setWidthPercentage(100);
                        personalTable.setSpacingAfter(15);
                        
                        personalTable.addCell(new PdfPCell(new Phrase("Nume complet:", normalFont)));
                        personalTable.addCell(new PdfPCell(new Phrase(nume + " " + prenume, normalFont)));
                        
                        personalTable.addCell(new PdfPCell(new Phrase("Functia:", normalFont)));
                        personalTable.addCell(new PdfPCell(new Phrase(functie, normalFont)));
                        
                        personalTable.addCell(new PdfPCell(new Phrase("Departament:", normalFont)));
                        personalTable.addCell(new PdfPCell(new Phrase(departament, normalFont)));
                        
                        personalTable.addCell(new PdfPCell(new Phrase("Email:", normalFont)));
                        personalTable.addCell(new PdfPCell(new Phrase(email, normalFont)));
                        
                        personalTable.addCell(new PdfPCell(new Phrase("Telefon:", normalFont)));
                        personalTable.addCell(new PdfPCell(new Phrase(telefon, normalFont)));
                        
                        if (dataAng != null) {
                            personalTable.addCell(new PdfPCell(new Phrase("Data angajarii:", normalFont)));
                            personalTable.addCell(new PdfPCell(new Phrase(new SimpleDateFormat("dd.MM.yyyy").format(dataAng), normalFont)));
                        }
                        
                        document.add(personalTable);
                        
                        // Statistici concedii
                        document.add(new Paragraph("STATISTICI CONCEDII", headerFont));
                        document.add(Chunk.NEWLINE);
                        
                        PdfPTable concediiTable = new PdfPTable(2);
                        concediiTable.setWidthPercentage(100);
                        concediiTable.setSpacingAfter(15);
                        
                        concediiTable.addCell(new PdfPCell(new Phrase("Concedii luate:", normalFont)));
                        concediiTable.addCell(new PdfPCell(new Phrase(String.valueOf(conluate), normalFont)));
                        
                        concediiTable.addCell(new PdfPCell(new Phrase("Zile consumate:", normalFont)));
                        concediiTable.addCell(new PdfPCell(new Phrase(String.valueOf(zilecons), normalFont)));
                        
                        concediiTable.addCell(new PdfPCell(new Phrase("Zile ramase:", normalFont)));
                        concediiTable.addCell(new PdfPCell(new Phrase(String.valueOf(zileramase), normalFont)));
                        
                        document.add(concediiTable);
                        
                        // Concedii detaliate
                        String concediiQuery = "SELECT c.start_c, c.end_c, c.motiv, c.durata, s.nume_status, tc.motiv as tip_concediu " +
                                             "FROM concedii c " +
                                             "JOIN statusuri s ON c.status = s.status " +
                                             "JOIN tipcon tc ON c.tip = tc.tip " +
                                             "WHERE c.id_ang = ? " +
                                             (reportType.equals("lunar") ? "AND MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE()) " :
                                              reportType.equals("trimestrial") ? "AND QUARTER(c.start_c) = QUARTER(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE()) " :
                                              reportType.equals("anual") ? "AND YEAR(c.start_c) = YEAR(CURDATE()) " : "") +
                                             "ORDER BY c.start_c DESC";
                        
                        PreparedStatement concediiStmt = connection.prepareStatement(concediiQuery);
                        concediiStmt.setInt(1, userId);
                        ResultSet concediiRs = concediiStmt.executeQuery();
                        
                        document.add(new Paragraph("DETALII CONCEDII", headerFont));
                        document.add(Chunk.NEWLINE);
                        
                        PdfPTable concediiDetailTable = new PdfPTable(5);
                        concediiDetailTable.setWidthPercentage(100);
                        concediiDetailTable.setSpacingAfter(15);
                        
                        // Header tabel
                        concediiDetailTable.addCell(new PdfPCell(new Phrase("Perioada", headerFont)));
                        concediiDetailTable.addCell(new PdfPCell(new Phrase("Tip", headerFont)));
                        concediiDetailTable.addCell(new PdfPCell(new Phrase("Motiv", headerFont)));
                        concediiDetailTable.addCell(new PdfPCell(new Phrase("Zile", headerFont)));
                        concediiDetailTable.addCell(new PdfPCell(new Phrase("Status", headerFont)));
                        
                        boolean hasConcedii = false;
                        while (concediiRs.next()) {
                            hasConcedii = true;
                            String perioada = new SimpleDateFormat("dd.MM.yyyy").format(concediiRs.getDate("start_c")) + 
                                            " - " + new SimpleDateFormat("dd.MM.yyyy").format(concediiRs.getDate("end_c"));
                            
                            concediiDetailTable.addCell(new PdfPCell(new Phrase(perioada, normalFont)));
                            concediiDetailTable.addCell(new PdfPCell(new Phrase(concediiRs.getString("tip_concediu"), normalFont)));
                            concediiDetailTable.addCell(new PdfPCell(new Phrase(concediiRs.getString("motiv"), normalFont)));
                            concediiDetailTable.addCell(new PdfPCell(new Phrase(String.valueOf(concediiRs.getInt("durata")), normalFont)));
                            concediiDetailTable.addCell(new PdfPCell(new Phrase(concediiRs.getString("nume_status"), normalFont)));
                        }
                        
                        if (!hasConcedii) {
                            PdfPCell noDataCell = new PdfPCell(new Phrase("Nu exista concedii in perioada selectata", normalFont));
                            noDataCell.setColspan(5);
                            noDataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                            concediiDetailTable.addCell(noDataCell);
                        }
                        
                        document.add(concediiDetailTable);
                        
                        // Proiecte si task-uri
                        document.add(new Paragraph("PROIECTE SI TASK-URI", headerFont));
                        document.add(Chunk.NEWLINE);
                        
                        String proiecteQuery = "SELECT DISTINCT p.nume, p.start, p.end, t.nume as task_nume, t.start as task_start, t.end as task_end, s.procent " +
                                             "FROM proiecte p " +
                                             "JOIN echipe e ON p.id = e.id_prj " +
                                             "JOIN membrii_echipe me ON e.id = me.id_echipa " +
                                             "LEFT JOIN tasks t ON p.id = t.id_prj AND t.id_ang = ? " +
                                             "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                             "WHERE me.id_ang = ? " +
                                             "ORDER BY p.start DESC";
                        
                        PreparedStatement proiecteStmt = connection.prepareStatement(proiecteQuery);
                        proiecteStmt.setInt(1, userId);
                        proiecteStmt.setInt(2, userId);
                        ResultSet proiecteRs = proiecteStmt.executeQuery();
                        
                        PdfPTable proiecteTable = new PdfPTable(4);
                        proiecteTable.setWidthPercentage(100);
                        proiecteTable.setSpacingAfter(15);
                        
                        // Header tabel proiecte
                        proiecteTable.addCell(new PdfPCell(new Phrase("Proiect", headerFont)));
                        proiecteTable.addCell(new PdfPCell(new Phrase("Task", headerFont)));
                        proiecteTable.addCell(new PdfPCell(new Phrase("Perioada Task", headerFont)));
                        proiecteTable.addCell(new PdfPCell(new Phrase("Progres", headerFont)));
                        
                        boolean hasProiecte = false;
                        while (proiecteRs.next()) {
                            hasProiecte = true;
                            proiecteTable.addCell(new PdfPCell(new Phrase(proiecteRs.getString("nume"), normalFont)));
                            
                            String taskNume = proiecteRs.getString("task_nume");
                            proiecteTable.addCell(new PdfPCell(new Phrase(taskNume != null ? taskNume : "N/A", normalFont)));
                            
                            java.sql.Date taskStart = proiecteRs.getDate("task_start");
                            java.sql.Date taskEnd = proiecteRs.getDate("task_end");
                            String perioada = "N/A";
                            if (taskStart != null && taskEnd != null) {
                                perioada = new SimpleDateFormat("dd.MM.yyyy").format(taskStart) + 
                                         " - " + new SimpleDateFormat("dd.MM.yyyy").format(taskEnd);
                            }
                            proiecteTable.addCell(new PdfPCell(new Phrase(perioada, normalFont)));
                            
                            int progres = proiecteRs.getInt("procent");
                            proiecteTable.addCell(new PdfPCell(new Phrase(progres + "%", normalFont)));
                        }
                        
                        if (!hasProiecte) {
                            PdfPCell noProjectsCell = new PdfPCell(new Phrase("Nu exista proiecte in perioada selectata", normalFont));
                            noProjectsCell.setColspan(4);
                            noProjectsCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                            proiecteTable.addCell(noProjectsCell);
                        }
                        
                        document.add(proiecteTable);
                        
                        // Informatii salariu (doar pentru anumite tipuri de raport)
                        if (reportType.equals("anual") || reportType.equals("complet")) {
                            document.add(new Paragraph("INFORMATII SALARIZARE", headerFont));
                            document.add(Chunk.NEWLINE);
                            
                            PdfPTable salariuTable = new PdfPTable(2);
                            salariuTable.setWidthPercentage(100);
                            salariuTable.setSpacingAfter(15);
                            
                            salariuTable.addCell(new PdfPCell(new Phrase("Salariu de baza:", normalFont)));
                            salariuTable.addCell(new PdfPCell(new Phrase(String.format("%.2f RON", salariu), normalFont)));
                            
                            // Sporuri active
                            String sporuriQuery = "SELECT ts.denumire, ts.procent FROM istoric_sporuri hs " +
                                                "JOIN tipuri_sporuri ts ON hs.tip_spor = ts.id " +
                                                "WHERE hs.id_ang = ? AND hs.data_start <= CURDATE() AND hs.data_final >= CURDATE()";
                            
                            PreparedStatement sporuriStmt = connection.prepareStatement(sporuriQuery);
                            sporuriStmt.setInt(1, userId);
                            ResultSet sporuriRs = sporuriStmt.executeQuery();
                            
                            StringBuilder sporuri = new StringBuilder();
                            while (sporuriRs.next()) {
                                if (sporuri.length() > 0) sporuri.append(", ");
                                sporuri.append(sporuriRs.getString("denumire"))
                                      .append(" (")
                                      .append(sporuriRs.getInt("procent"))
                                      .append("%)");
                            }
                            
                            salariuTable.addCell(new PdfPCell(new Phrase("Sporuri active:", normalFont)));
                            salariuTable.addCell(new PdfPCell(new Phrase(sporuri.length() > 0 ? sporuri.toString() : "Niciun spor activ", normalFont)));
                            
                            document.add(salariuTable);
                        }
                        
                        // Footer
                        document.add(Chunk.NEWLINE);
                        document.add(Chunk.NEWLINE);
                        Paragraph footer = new Paragraph("Raport generat la data de " + 
                                        new SimpleDateFormat("dd.MM.yyyy HH:mm").format(new java.util.Date()), smallFont);
                        footer.setAlignment(Element.ALIGN_RIGHT);
                        document.add(footer);
                        
                    } else {
                        document.add(new Paragraph("Utilizator nu a fost gasit!", headerFont));
                    }
                    
                } catch (SQLException e) {
                    document.add(new Paragraph("Eroare la accesarea bazei de date: " + e.getMessage(), normalFont));
                }
                
                document.close();
                
            } catch (Exception e) {
                response.setContentType("text/html");
                out.println("<script>alert('Eroare la generarea PDF: " + e.getMessage() + "'); history.back();</script>");
            }
            
        } else {
            response.sendRedirect("login.jsp");
        }
    } else {
        response.sendRedirect("login.jsp");
    }
%>