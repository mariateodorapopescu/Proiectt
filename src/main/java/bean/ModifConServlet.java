package bean;
// importare biblioteci
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
/**
 * Clasa ce implementeaza ModifConServlet
 */
@WebServlet(asyncSupported = true)
public class ModifConServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * constructor
     * @see HttpServlet#HttpServlet()
     */
    public ModifConServlet() {
        super();
    }
    
    private ModifConDao concediu; // dao ca sa modific concediul/sa fac legatura la baza de date

    /**
     * initializarea datelor de clasa
     */
    public void init() {
        concediu = new ModifConDao();
    }
    
	/**
	 * in cazul in care se face un get pe server, serverul e mai mult folosit pentru post
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// declarare si initializare variabile
		// date despre concediu
		int id = Integer.valueOf(request.getParameter("idcon"));
		int tip = Integer.valueOf(request.getParameter("tip"));
		String inceput = request.getParameter("start");
		String sfarsit = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");
    	
    	// extra date despre concediu
    	int durata1 = 0;
   	 	LocalDate inceput2 = LocalDate.parse(inceput);
	    LocalDate sfarsit2 = LocalDate.parse(sfarsit);
	    long durata0 = ChronoUnit.DAYS.between(inceput2, sfarsit2); 
	    int uid = -1;
        String sql = "select id_ang from concedii where id = ?;";
        durata1 = (int)durata0;
        final int durata2 = durata1;
        
	    // un concediu propriu zis ca sa incarc in dao si baza de date
	    Concediu concediul = new Concediu();
	
		durata1 = (int) durata0;
        concediul.setId(id);
        concediul.setTip(tip);
        concediul.setInceput(inceput);
        concediul.setSfarsit(sfarsit);
        concediul.setMotiv(motiv);
        concediul.setLocatie(locatie);
        concediul.setDurata(durata1);
        
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); 
		        PreparedStatement stm = conexiune.prepareStatement(sql)) {
		        stm.setInt(1, id);
		        try (ResultSet rezultat = stm.executeQuery()) {
		            if (rezultat.next()) {
		                uid = rezultat.getInt("id_ang");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date", e);
		    }
	    final int uid2 = uid;
	    // verificari concordanta date concediu -> majoritatea sunt cu try&catch pentru ca se bazeaza pe request, response, concediu
        // cum majoritatea metodelor implementate pentru verificarea concordantei concediului sunt similare, 
        // au acelasi tip de erori, functioneaza dupa acelasi principiu, difera numai interogarea in baza de date, alte cateva variabile
	    try {
        	// verificare daca are mai mult de 3 concedii pe an
			if (maimulteconcedii(request)) {
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul nu poate avea mai mult de 3 perioade diefrite de concediu!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu a gasit clasa - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		} catch (IOException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
			PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare IO - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		}
        
        try {
			if (!maimultezile(request)) {
				// verificare daca are mai mult de 30 sau 40 de zile de concediu pe an
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul are deja prea multe zile de concediu!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu a gasit clasa - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		} catch (IOException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
			PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare IO - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		}
        
        try {
			if (!odatavara(request, concediul) && (stringToDate(concediul.getInceput()).getLuna() >= 6 && stringToDate(concediul.getInceput()).getLuna() <= 8)) {
				// verificare daca are deja un concediu pe perioada verii
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Utilizatorul nu poate avea mai mult de un concediu pe timpul verii!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu a gasit clasa - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		} catch (IOException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
			PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare IO - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		}
        
        if (!maimultezileodata(concediul)) {
        	// verificare daca are mai mult de 21 de concediu pe o perioada de concediu
        	response.setContentType("text/html;charset=UTF-8");
        	PrintWriter out = response.getWriter();
			out.println("<script type='text/javascript'>");
		    out.println("alert('Utilizatorul nu poate avea mai mult de 21 de zile / concediu!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			return;
		}
        
        try {
			if (!preamulti(concediul, request)) {
				// verificare daca sunt prea multi angajati (mai mult de jumatate) dintr-un departament plecati in concediu
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script type='text/javascript'>");
			    out.println("alert('Au concediu prea multi utilizatori dintr-un singur departament!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
				return;
			}
		} catch (ClassNotFoundException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu a gasit clasa - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		} catch (IOException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			response.setContentType("text/html;charset=UTF-8");
			PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Eroare IO - debug only!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
		    e.printStackTrace();
		}
        
        // acum, diferit de celalte metode, se verifica tipul de utilizator pentru ca daca este sef (3) sau director (0), nu pot fi 2/departament
        String sql2 = "select * from useri where id = ?;"; // interogarea este un string
	    int tip2 = -1; // pentru cazul in care nu se gaseste nimic in baza de date sau introgarea nu este corecta, ar ramane -1
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); 
	    		// se creaza conexiune (uneori mai puneam si Class.forName pentru driver, acum a mers si asa
		        PreparedStatement stm = conexiune.prepareStatement(sql2)) { //se pregateste pentru a face interogarea
		        stm.setInt(1, id); // adaug variabile
		        try (ResultSet rezultat = stm.executeQuery()) { // se executa interogarea
		            if (rezultat.next()) { // se extrag date din rezultatul interogarii, mai exact tipul de utilizator care a adaugat concediul
		                tip2 = rezultat.getInt("tip");
		            }
		        }
		    } catch (SQLException e) { // interogarile pot arunca exceptii si daca da, atunci semnalizez cu alerta si redirectare la pagina de adaugare/modificare concediu
		        printSQLException(e);
		        response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare la baza de date - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
		        throw new IOException("Eroare la baza de date =(", e);
		    }
	    
	    if (tip2 == 0) {
	    	// daca utilizatorul este director, pot face verificarea sa nu fie mai mult de 2 directori plecati
	    	 try {
	 			if (!preamultid(concediul, request)) {
	 				response.setContentType("text/html;charset=UTF-8");
	 				PrintWriter out = response.getWriter();
					out.println("<script type='text/javascript'>");
				    out.println("alert('Au concediu prea multi directori!');");
				    out.println("window.location.href = 'actiuni.jsp';");
				    out.println("</script>");
				    out.close();
					return;
				}
			} catch (ClassNotFoundException e) {
				// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
				response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu a gasit clasa - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
			} catch (IOException e) {
				// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Eroare IO - debug only!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    e.printStackTrace();
			}
	    }
	    
	    // daca utilizatorul este director sau sef, atunci concediul este deja aprobat sef, altfel este neaprobat
	    if (tip2 == 0 || tip2 == 3) {
	    	concediul.setStatus(1);
	    } else {
	    	concediul.setStatus(0);
	    }
	    
	    // verificare daca se incareaza in numarul de zile conform tipului de concediu (concediu medical, concediu de odihna, concediu fara plata etc)
	    try {
			if (oktip(concediul)) {
			    response.setContentType("text/html;charset=UTF-8");
			    PrintWriter out = response.getWriter();
			    out.println("<script type='text/javascript'>");
			    out.println("alert('Nu poate avea mai multe zile decat tipul concediului!');");
			    out.println("window.location.href = 'actiuni.jsp';");
			    out.println("</script>");
			    out.close();
			    return; 
			}
		} catch (SQLException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			e.printStackTrace();
			response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Eroare la baza de date!');");
	        out.println("window.location.href = 'actiuni.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
		} catch (IOException e) {
			// daca este eroare, apare alerta + se intoarce la pagina de actiuni, adaugare/modficiare/stergere concediu
			e.printStackTrace();
			response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Eroare la baza de date!');");
	        out.println("window.location.href = 'actiuni.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
		}
	    
	    // hai sa facem un before and after =)
        String inceputold = "";
        String sfarsitold = "";
        String locatieold = "";
        String motivold = "";
        String tipold = "";
        int tipold2 = -1;
        int durataold2 = -1;
        String data = "";
        try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
      	         PreparedStatement stmt = conexiune.prepareStatement("select datediff(end_c, start_c) as durata from concedii where id = ?;"); 
        		PreparedStatement stmt2 = conexiune.prepareStatement("select * from concedii where id = ?;");
        		PreparedStatement stmt3 = conexiune.prepareStatement("select motiv from tipcon where tip = ?;")
        				) {
      	        stmt.setInt(1, id);
      	        ResultSet rs = stmt.executeQuery();
      	        if (rs.next()) {
      	            
      	            durataold2 = rs.getInt("durata") + 1;
      	        }
      	        
      	      stmt2.setInt(1, id);
     	        ResultSet rs2 = stmt2.executeQuery();
     	        if (rs2.next()) {
     	            inceputold = rs2.getString("start_c");
     	            sfarsitold = rs2.getString("end_c");
     	            locatieold = rs2.getString("locatie");
     	            motivold = rs2.getString("motiv");
     	            tipold2 = rs2.getInt("tip");
     	            data = rs2.getString("added");
     	        }
     	        
    	        stmt3.setInt(1, tipold2);
    	        ResultSet rs3 = stmt3.executeQuery();
    	        if (rs3.next()) {
    	        }
     	        
      	    } catch (SQLException e) {
      	        throw new ServletException("Eroare BD =(", e);
      	    }
	    final String inceputold2 = inceputold;
	    final String sfarsitold2 = sfarsitold;
	    final String tipold21 = tipold;
	    final String locatieold2 = locatieold;
	    final String motivold21 = motivold;
	    final int durataold21 = durataold2;
	    final String dataold2 = data;
	    // cum la neindeplinirea unei reguli de verificare a concediului se intampla redirectare si return, 
	    // daca a ajuns in acest punct inseamna ca concediul este valid si, deci, se poate incarca in baza de date
        try {
            concediu.check(concediul);
            
         // aici vine partea asincrona
           
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            

            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send2(uid2, id, tip, inceput, sfarsit, motiv, locatie, durata2, inceputold2, sfarsitold2, locatieold2, motivold21, tipold21, durataold21, dataold2);
                    asyncContext.complete();  // Completarea actiunii asincrone
                } catch (Exception e) {
                    e.printStackTrace();  // in caz de eroare, afisez in concola serverului sa vad de ce + redirectare la pagina de adaugare/modificare concediu + alerta
                    asyncContext.complete();  // Context asincron finalizat indiferent de situatie
                    response.setContentType("text/html;charset=UTF-8");
        	        PrintWriter out = null;
					try {
						out = response.getWriter();
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
        	        out.println("<script type='text/javascript'>");
        	        out.println("alert('eroare din cauze necunoscute!');");
        	        out.println("window.location.href = 'actiuni.jsp';");
        	        out.println("</script>");
        	        out.close();
        	        return; 
                    
                }
            });
            
            // abia dupa ce trimit mail-ul trec mai departe             
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Modificare cu succes!');");
		    out.println("window.location.href = 'concediinoieu.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut modifica din motive necunoscute.');");
		    out.println("window.location.href = 'concediinoieu.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}
	
	/**
	 * verificare daca se incareaza in numarul de zile conform tipului de concediu (concediu medical, concediu de odihna, concediu fara plata etc)
	 * @param concediul
	 * @return true daca durata concediului este mai mica decat cea prevazuta pentru acel tip de concediu
	 * @throws SQLException
	 */
	private boolean oktip(Concediu concediul) throws SQLException {
		// declarare si initializare variabile
		String inceput = concediul.getInceput();
		String sfarsit = concediul.getSfarsit();
		LocalDate inceput2 = LocalDate.parse(inceput);
	    LocalDate sfarsit2 = LocalDate.parse(sfarsit);
	    long durata = ChronoUnit.DAYS.between(inceput2, sfarsit2) + 1; // ultimul - primul + 1
	    int durata2 = 0;
	    durata2 = (int) durata + 1;
	    int durata3 = 0;
		String sql = "select nr_zile from tipcon;";
	   
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		        PreparedStatement stm = conexiune.prepareStatement(sql)) {
		        try (ResultSet rezultat = stm.executeQuery()) {
		            if (rezultat.next()) {
		                durata3 = rezultat.getInt("nr_zile");
		            }
		        }
		    } 
	    
	    return durata3 < durata2;
	}
	
	/**
	 * verificare daca are deja mai mult de 3 concedii pe an
	 * @param request
	 * @return true daca are mai mult de 3 perioade diferite de concediu pe an
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public static boolean maimulteconcedii(HttpServletRequest request) throws ClassNotFoundException, IOException {
		// declarare si initializare variabile
	    int nr = 0;
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    String sql = "SELECT * FROM useri WHERE useri.id = ?;";
	    int id = Integer.valueOf(request.getParameter("userId"));

	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        PreparedStatement stm = conexiune.prepareStatement(sql)) {
	        stm.setInt(1, id);
	        try (ResultSet rs = stm.executeQuery()) {
	            if (rs.next()) {
	                nr = rs.getInt("conramase"); // aici da, le ia pe alea cu status pozitiv sau 0
	            }
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date", e);
	    }

	    return nr > 3;
	}
	
	/**
	 * verificare daca are deja mai multe zile pe an
	 * @param request
	 * @return true daca are mai mult de 30/40 zile de concediu luate per total pe an
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public static boolean maimultezile(HttpServletRequest request) throws ClassNotFoundException, IOException {
		// initializare si declarare variabile
	    int nr = 0;
	    int id = Integer.valueOf(request.getParameter("userId"));
	    Set<LocalDate> libere = getLibereLegale();
	    String sql = "SELECT start_c, end_c FROM concedii WHERE id_ang = ? and status >= 0;";
	    String sql2 = "select * from useri where id = ?;";
	    int tip = 0;
	    
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    	PreparedStatement stm = conexiune.prepareStatement(sql);  
	    	PreparedStatement stm2 = conexiune.prepareStatement(sql2)) {
	        stm2.setInt(1, id);
	        try (ResultSet rezultat = stm2.executeQuery()) {
	            if (rezultat.next()) {
	                tip = rezultat.getInt("tip");
	            }
	        }
	        
	        stm.setInt(1, id);
	        try (ResultSet rezultat = stm.executeQuery()) {
	            while (rezultat.next()) {
	                LocalDate inceput = rezultat.getDate("start_c").toLocalDate();
	                LocalDate sfarsit = rezultat.getDate("end_c").toLocalDate();
	                while (!inceput.isAfter(sfarsit)) {
	                    if (!libere.contains(inceput)) {
	                        nr++;
	                    }
	                    inceput = inceput.plusDays(1);
	                }
	            }
	        }
	        
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date", e);
	    }
	    
	    // daca e utilizator de tip 2, atunci nu are voie mai mult de 30 zile, altfel are 40
	    if (tip == 2) {
	        return nr < 30;
	    }
	    
	    return nr < 40;
	}
	
	/**
	 * 
	 * @return map cu liberele legale
	 */
	public static Set<LocalDate> getLibereLegale() {
	    return new HashSet<>(Arrays.asList(
	        LocalDate.of(LocalDate.now().getYear(), 1, 1),
	        LocalDate.of(LocalDate.now().getYear(), 1, 2),
	        LocalDate.of(LocalDate.now().getYear(), 1, 6),
	        LocalDate.of(LocalDate.now().getYear(), 1, 7),
	        LocalDate.of(LocalDate.now().getYear(), 1, 24),
	        LocalDate.of(LocalDate.now().getYear(), 5, 1),
	        LocalDate.of(LocalDate.now().getYear(), 6, 1),
	        LocalDate.of(LocalDate.now().getYear(), 8, 15),
	        LocalDate.of(LocalDate.now().getYear(), 11, 30),
	        LocalDate.of(LocalDate.now().getYear(), 12, 1),
	        LocalDate.of(LocalDate.now().getYear(), 12, 25),
	        LocalDate.of(LocalDate.now().getYear(), 12, 26)
	    ));
	}
	
	public static boolean odatavara(HttpServletRequest request, Concediu concediu) throws ClassNotFoundException, IOException{
		// declarare si initializare variabile
		int nr = 0;
		String sql = "SELECT count(*) as total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE id_ang = ? AND MONTH(start_c) >=6 AND MONTH(start_c) <= 8 and concedii.id <> ? and concedii.status >= 0;";
	    int id = Integer.valueOf(request.getParameter("idcon"));
	    int uid = -1;
        String sql2 = "select id_ang from concedii where id = ?;";
        
	    Class.forName("com.mysql.cj.jdbc.Driver");
	   
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // aci crapa
		        PreparedStatement stm = conexiune.prepareStatement(sql2); 
	    		PreparedStatement preparedStatement = conexiune.prepareStatement(sql)) {
		        stm.setInt(1, id);
		        try (ResultSet rezultat = stm.executeQuery()) {
		            if (rezultat.next()) {
		                uid = rezultat.getInt("id_ang");
		            }
		        }
		        preparedStatement.setInt(1, uid);
		        preparedStatement.setInt(2, id);
		        try (ResultSet rs = preparedStatement.executeQuery()) {
		            if (rs.next()) {
		                nr = rs.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date =(", e);
		    }

	    return nr < 1;
	}
	
	/**
	 * Functie ce numara cate zile sunt intre 2 date de tipul Data creat de mine
	 * @param startt
	 * @param endd
	 * @return numarul de zile dintre doua date
	 */
	public static int contor(Data startt, Data endd) {
		int contor = 0;
        if (startt.getLuna() == endd.getLuna()) {
            contor = endd.getZi() - startt.getZi() + 1;
        } else {
            if (startt.getLuna() == 1 || startt.getLuna() == 3 || startt.getLuna() == 5 || startt.getLuna() == 7
                    || startt.getLuna() == 8 || startt.getLuna() == 10 || startt.getLuna() == 12) {
                contor = 31 - startt.getZi() + endd.getZi() + 1;
            } else if (startt.getLuna() == 4 || startt.getLuna() == 6 || startt.getLuna() == 9 || startt.getLuna() == 11) {
                contor = 30 - startt.getZi() + endd.getZi() + 1;
            } else {
                if (startt.getAn() % 4 == 0) {
                    contor = 29 - startt.getZi() + endd.getZi() + 1;
                } else {
                    contor = 28 - startt.getZi() + endd.getZi() + 1;
                }
            }
        }
        return contor;
    }
	
	/**
	 * verificare numar de zile / concediu
	 * @param concediu
	 * @return daca un concediu are mai mult de 21 de zile
	 */
	public static boolean maimultezileodata(Concediu concediu) {
		 int nr = 0;
		 Data start_c = stringToDate(concediu.getInceput());
	     Data end_c = stringToDate(concediu.getSfarsit());
	     nr = contor(start_c, end_c);
	     return nr < 21;
	}
	
	/**
	 * Transformare tip de date din String in date
	 * @param dateString
	 * @return data in format Data
	 */
	public static Data stringToDate(String dateString) {
        String[] parts = dateString.split("-");
        int an = Integer.parseInt(parts[0]);
        int luna = Integer.parseInt(parts[1]);
        int zi = Integer.parseInt(parts[2]);
        return new Data(zi, luna, an);
    }
	
	/**
	 * Verificare daca intr-un departament sunt plecati mai mult de jumatate de angajati
	 * @param concediu
	 * @param request
	 * @return
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public static boolean preamulti(Concediu concediu, HttpServletRequest request) throws ClassNotFoundException, IOException {
		// declarare si initializare date
	    int nr = -1;
	    int total = -1;
	    int depid = -1;
	    String sql = "SELECT id_dep FROM useri WHERE id = ?";
	    String sql2 = "SELECT COUNT(*) AS total FROM useri WHERE id_dep = ?";
	    String sql3 = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON useri.id = concedii.id_ang " +
	        "WHERE useri.id_dep = ? AND start_c >= ? AND end_c <= ? and status > 0";
	    int id = Integer.parseInt(request.getParameter("userId"));

	    Class.forName("com.mysql.cj.jdbc.Driver");

	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        PreparedStatement stmt = conexiune.prepareStatement(sql);  
	    	PreparedStatement stmt2 = conexiune.prepareStatement(sql2);
	    	PreparedStatement stmt3 = conexiune.prepareStatement(sql3)){
	    	
	    	Data inceput = stringToDate(concediu.getInceput());
	        Data sfarsit = stringToDate(concediu.getSfarsit());

	        stmt.setInt(1, id);
	        try (ResultSet rezultat = stmt.executeQuery()) {
	            if (rezultat.next()) {
	                depid = rezultat.getInt("id_dep");
	            }
	        }
	        
	        stmt2.setInt(1, depid);
	        try (ResultSet rsTotalUsers = stmt2.executeQuery()) {
	            if (rsTotalUsers.next()) {
	                total = rsTotalUsers.getInt("total");
	            }
	        }

	        stmt3.setInt(1, depid);
	        stmt3.setDate(2, java.sql.Date.valueOf(inceput.getAn() + "-" + inceput.getLuna() + "-" + inceput.getZi()));
	        stmt3.setDate(3, java.sql.Date.valueOf(sfarsit.getAn() + "-" + sfarsit.getLuna() + "-" + sfarsit.getZi()));
	        try (ResultSet rsTotalLeaves = stmt3.executeQuery()) {
	            if (rsTotalLeaves.next()) {
	                nr = rsTotalLeaves.getInt("total");
	            }
	        }
		        
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date", e);
	    }
	    
	    return nr < (total / 2);
	}
	
	/**
	 * Verificare daca mai mult de 2 directori sunt plecati in concediu
	 * @param concediu
	 * @param request
	 * @return true, daca daca mai mult de 2 directori sunt plecati in concediu
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public static boolean preamultid(Concediu concediu, HttpServletRequest request) throws ClassNotFoundException, IOException{
		// declarare si initializare variabile
		int nr = 0;
		String sql = "select count(*) as total from concedii join useri on useri.id = concedii.id_ang where day(start_c) >= ? and month(start_c) = ?"
				+ " and day(start_c) <= ? and month(start_c) <= ? and status > 0 group by useri.tip having useri.tip = 0;";
		Data inceput = stringToDate(concediu.getInceput());
        Data sfarsit = stringToDate(concediu.getSfarsit());
	    Class.forName("com.mysql.cj.jdbc.Driver");
	    
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	        PreparedStatement stm = conexiune.prepareStatement(sql)) {

	        stm.setInt(1, inceput.getZi());
	        stm.setInt(2, inceput.getLuna());
	        stm.setInt(3, sfarsit.getZi());
	        stm.setInt(4, sfarsit.getLuna());
	        try (ResultSet rezultat = stm.executeQuery() ) {
	            if (rezultat.next()) {
	                nr = rezultat.getInt("total");
	            }
	        }
	    } catch (SQLException e) {
	        printSQLException(e);
	        throw new IOException("Eroare la baza de date", e);
	    }

	    return nr < 2;
		}
	
	/**
	 * Afiseaza frumos / Pretty print o eroare dintr-o baza de date
	 * @param ex
	 */
	private static void printSQLException(SQLException ex) {
        for (Throwable e: ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                System.err.println("Stare: " + ((SQLException) e).getSQLState());
                System.err.println("Cod eroare: " + ((SQLException) e).getErrorCode());
                System.err.println("Explicatie: " + e.getMessage());
                Throwable t = ex.getCause();
                while (t != null) {
                    System.out.println("Cauza: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}
