package bean;
// importuri de librarii
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
/**
 * 
 * Acest Servlet se ocupa cu adaugarea de concedii
 */
public class AddConServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
     * constructor
     */
    public AddConServlet() {
        super();
    }
    
    /**
     * Dao ca sa incarce datele
     */
    private AdaugaConcediuDAO concediu;
    
    /**
     * initializare
     */
    public void init() {
        concediu = new AdaugaConcediuDAO();
    }
    
    /**
     * In cazul in care se face get pe server
     */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Nu se poate face get =(");
	}

	/**
	 * Functie care se ocupa cu transformarea unui String "YYYY-MM-DD" in data din java.util
	 * @param data
	 * @return Data Java
	 */
	protected Data toData(String data) {
		 String[] parts = data.split("-");
	        int an = Integer.parseInt(parts[0]);
	        int luna = Integer.parseInt(parts[1]);
	        int zi = Integer.parseInt(parts[2]);
	        return new Data(zi, luna, an);
	}
	
	/**
	 * metoda post din server
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// declarare si initializare date
		int id = Integer.valueOf(request.getParameter("userId")); // pentru interogari urmatoare
		
		// pentru a crea concediul
		String inceput = request.getParameter("start");
		String sfarsit = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");
    	int tip = Integer.valueOf(request.getParameter("tip"));
    	
    	// extra date despre concediu
    	int durata = 0;
    	LocalDate inceput2 = LocalDate.parse(inceput);
		LocalDate sfarsit2 = LocalDate.parse(sfarsit);
		long diferenta1 = ChronoUnit.DAYS.between(inceput2, sfarsit2) + 1; 
		Set<LocalDate> libere = new HashSet<>();
	    int an = inceput2.getYear(); 
	    
	    // concediu ca sa il incarc in Dao
	    Concediu concediul = new Concediu();
	    
	    // verificari coerenta planificare concediu a datelor de inceput si final
	    durata = (int) diferenta1 + 1;
	    if (sfarsit2.isBefore(inceput2)) {
	        throw new IOException("Data de final nu poate fi inaintea celei de inceput!");
	    }
	    final int durata2 = durata;
	    
	    // verificare daca concediul este in liberele legale, ca sa nu se numere
	    libere.add(LocalDate.of(an, 1, 1)); 
	    libere.add(LocalDate.of(an, 1, 2)); 
	    libere.add(LocalDate.of(an, 1, 6)); 
	    libere.add(LocalDate.of(an, 1, 7));
	    libere.add(LocalDate.of(an, 1, 24)); 
	    libere.add(LocalDate.of(an, 5, 1)); 
	    libere.add(LocalDate.of(an, 6, 1)); 
	    libere.add(LocalDate.of(an, 8, 15));
	    libere.add(LocalDate.of(an, 11, 30)); 
	    libere.add(LocalDate.of(an, 12, 1));
	    libere.add(LocalDate.of(an, 12, 25));
	    libere.add(LocalDate.of(an, 12, 26)); 
		    
        // incarcare date in obiect de tip Concediu
        concediul.setId_ang(id);
        concediul.setInceput(inceput);
        concediul.setSfarsit(sfarsit);
        concediul.setMotiv(motiv);
        concediul.setLocatie(locatie);
        concediul.setTip(tip);
        concediul.setDurata((durata + 1));
      
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
			if (!odatavara(request) && (toData(concediul.getInceput()).getLuna() >= 6 && toData(concediul.getInceput()).getLuna() <= 8)) {
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
	    
	    // daca exista deja un concediu cu aceleasi date in baza de date, atunci e duplicat si, deci, nu se adauga
	    if (concediuExista(id, inceput2, sfarsit2)) {
	        response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Concediul specificat există deja!');");
	        out.println("window.location.href = 'actiuni.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
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
	    
	    // cum la neindeplinirea unei reguli de verificare a concediului se intampla redirectare si return, 
	    // daca a ajuns in acest punct inseamna ca concediul este valid si, deci, se poate incarca in baza de date
	    
        try {
            concediu.incarca(concediul);
            
            // aici vine partea asincrona
            // incercare 1
            /*
            ExecutorService executorService = Executors.newSingleThreadExecutor();
            executorService.submit(() -> {
            	// public void send(int uid, int tip, String start, String end, String motiv, String locatie, int durata) throws ServletException {
                try {
					Async1.send(uid, tip, start, end, motiv, locatie, durataa);
				} catch (ServletException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            });
            executorService.shutdown();  // Oprește executorul după trimiterea emailului
            */
            
            // se doreste varianta cu servlet asincron, nu cu mai multe thread-uri.
            // daca ar fi mai multe thread-uri, server-ul s-ar incarca prea mult si ar deveni indisponibil -> neok
            // jakarta este javax nou
            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
            // asyncContext.setTimeout(1000); 
            // get timeout, dispatch
            // java6
            
            asyncContext.start(() -> {
                try {
                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
                    MailAsincron.send(id, tip, inceput, sfarsit, motiv, locatie, durata2);
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
            
            // abia dupa ce trimit mail-ul trec mai departe , adica se face redirectare la pagina de vizualizare a concediilor personale, ca sa poata vedea ca acel concediu a fost adaugat
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Adaugare cu succes!');");
		    out.println("window.location.href = 'concediinoisef.jsp?pag=1';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	// adica se face redirectare la pagina de actiuni ca sa adauge inca o data
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut adauga concediul din motive necunoscute.');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}
	
	/**
	 * Pasii urmati la celelate functii ajutatoare sunt in mare
	 * declarare si initializare variabile
	 * incarcare driver baza de date
	 * creare conexiune baza de date
	 * pregatirea unei interogari
	 * executia unei interogari
	 * returnare false sau true sau returnare un numar de la un count sau -1
	 */
	
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
	 * verificare daca are deja acelasi concediu (conform datelor de inceput si final) incarcat
	 * @param id
	 * @param inceput
	 * @param sfarsit
	 * @return true daca a numarat deja un concediu al acelei persoane in aceeasi perioada
	 * @throws ServletException
	 */
	private boolean concediuExista(int id, LocalDate inceput, LocalDate sfarsit) throws ServletException {
		
	    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	    		
	        PreparedStatement stmt = conexiune.prepareStatement("SELECT COUNT(*) FROM concedii WHERE id_ang = ? AND start_c = ? AND end_c = ? and status >= 0")) {
	    	
	        stmt.setInt(1, id);
	        stmt.setDate(2, java.sql.Date.valueOf(inceput));
	        stmt.setDate(3, java.sql.Date.valueOf(sfarsit));
	        
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return rs.getInt(1) > 0;
	        }	
	        
	    } catch (SQLException e) {
	        throw new ServletException("Database error checking for existing leave", e);
	    }
	    return false;
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
		
		/**
		 * verificare daca are deja un concediu pe timpul verii
		 * @param request
		 * @return true daca are deja un concediu, diferit de acesta, pe timpul verii
		 * @throws ClassNotFoundException
		 * @throws IOException
		 */
		public static boolean odatavara(HttpServletRequest request) throws ClassNotFoundException, IOException{
			// initializare si declarare variabile
			int nr = 0;
			int id = Integer.valueOf(request.getParameter("userId"));
			
		    String sql = "SELECT count(*) as total FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE id_ang = ? AND MONTH(start_c) >=6 AND MONTH(start_c) <= 8 and concedii.status >= 0;";
		    
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		        PreparedStatement stm = conexiune.prepareStatement(sql)) {
		        stm.setInt(1, id);
		        try (ResultSet rezultat = stm.executeQuery()) {
		            if (rezultat.next()) {
		                nr = rezultat.getInt("total");
		            }
		        }
		    } catch (SQLException e) {
		        printSQLException(e);
		        throw new IOException("Eroare la baza de date =(", e);
		    }

		    return nr < 1;
		}
		
		/**
		 * verificare numar de zile / concediu
		 * @param concediu
		 * @return daca un concediu are mai mult de 21 de zile
		 */
		public static boolean maimultezileodata(Concediu concediu) {
			// declarare si initializare variabile
		    LocalDate inceput = LocalDate.parse(concediu.getInceput());
		    LocalDate sfarsit = LocalDate.parse(concediu.getSfarsit());
		    Set<LocalDate> libere = getLibereLegale();
		    int nr = 0;
		    LocalDate datacurenta = inceput;
		    
		    while (!datacurenta.isAfter(sfarsit)) {
		    	// ca sa nu am diferenta de zile negativa
		        if (!libere.contains(datacurenta)) {
		        	// efectiv numar
		            nr++;
		        }
		        datacurenta = datacurenta.plusDays(1);
		    }

		    return nr < 21;
		}
		
		/**
		 * Transformare tip de date din String in date
		 * @param dateString
		 * @return data in format Data
		 */
		public static Data stringToDate(String dateString) {
			// declarare si initializare variabile
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
		    Data inceput = stringToDate(concediu.getInceput());
	        Data sfarsit = stringToDate(concediu.getSfarsit());
		    
		    int id = Integer.parseInt(request.getParameter("userId"));
		    
		    String sql = "SELECT id_dep FROM useri WHERE id = ?";
		    String sql2 = "SELECT COUNT(*) AS total FROM useri WHERE id_dep = ?";
		    String sql3 = "SELECT COUNT(*) AS total FROM concedii JOIN useri ON useri.id = concedii.id_ang " +
		        "WHERE useri.id_dep = ? AND start_c >= ? AND end_c <= ? and status > 0";
	
		    Class.forName("com.mysql.cj.jdbc.Driver");

		    try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
		        PreparedStatement stmt = conexiune.prepareStatement(sql);  
		    	PreparedStatement stmt2 = conexiune.prepareStatement(sql2);
		    	PreparedStatement stmt3 = conexiune.prepareStatement(sql3)){

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
			Data inceput = stringToDate(concediu.getInceput());
	        Data sfarsit = stringToDate(concediu.getSfarsit());
	        
			String sql = "select count(*) as total from concedii join useri on useri.id = concedii.id_ang where day(start_c) >= ? and month(start_c) = ?"
					+ " and day(start_c) <= ? and month(start_c) <= ? and status > 0 group by useri.tip having useri.tip = 0;";
			
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
