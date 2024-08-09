package bean;

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

import bean.ConcediuCon;
import bean.ConcediuConDao;
/**
 * Servlet implementation class AddConServlet
 */
public class DelConServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DelConServlet() {
        super();
        // TODO Auto-generated constructor stub
    }
    
    private DelConDao concediu;

    public void init() {
        concediu = new DelConDao();
    }
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//doGet(request, response);
//		int uid = Integer.valueOf(request.getParameter("userId"));
		int id = Integer.valueOf(request.getParameter("idcon"));
		String start = request.getParameter("start");
		String end = request.getParameter("end");
    	String motiv = request.getParameter("motiv");
    	String locatie = request.getParameter("locatie");

        ConcediuCon con = new ConcediuCon();
        con.setId(id);
//        con.setId_ang(uid);
        con.setStart(start);
        con.setEnd(end);
        con.setMotiv(motiv);
        con.setLocatie(locatie);
        
        try {
            concediu.check(con);
            // si la stergere trimit notificari ca de ce nu =))
  GMailServer sender = new GMailServer("liviaaamp@gmail.com", "rtmz fzcp onhv minb");
            
            // hai sa facem un before 
            String starto = "";
            String endo = "";
            String loco = "";
            String motivo = "";
            String tipo = "";
            String motivvo = "";
            int tippo = -1;
            int durato = -1;
            String data = "";
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
          	         PreparedStatement stmt = connection.prepareStatement("select datediff(end_c, start_c) as durata from concedii where id = ?;"
          	         		+ "")) {
          	        stmt.setInt(1, id);
          	        
          	        ResultSet rs = stmt.executeQuery();
          	        if (rs.next()) {
          	            
          	            durato = rs.getInt("durata") + 1;
          	        }
          	    } catch (SQLException e) {
          	        throw new ServletException("Eroare BD =(", e);
          	    }
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select * from concedii where id = ?;"
       	         		+ "")) {
       	        stmt.setInt(1, id);
       	        
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	            starto = rs.getString("start_c");
       	            endo = rs.getString("end_c");
       	            loco = rs.getString("locatie");
       	            motivo = rs.getString("motiv");
       	            tippo = rs.getInt("tip");
       	            data = rs.getString("added");
       	        }
       	    } catch (SQLException e) {
       	        throw new ServletException("Eroare BD =(", e);
       	    }
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         	         PreparedStatement stmt = connection.prepareStatement("select motiv from tipcon where tip = ?;")) {
         	        stmt.setInt(1, tippo);
         	        
         	        ResultSet rs = stmt.executeQuery();
         	        if (rs.next()) {
         	            motivvo = rs.getString("motiv");
         	            
         	        }
         	    } catch (SQLException e) {
         	        throw new ServletException("Eroare BD=(", e);
         	    }
            int uid = -1;
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
          	         PreparedStatement stmt = connection.prepareStatement("select id_ang from concedii where id = ?;"
          	         		+ "")) {
          	        stmt.setInt(1, id);
          	        
          	        ResultSet rs = stmt.executeQuery();
          	        if (rs.next()) {
          	            
          	            uid = rs.getInt("id_ang");
          	        }
          	    } catch (SQLException e) {
          	        throw new ServletException("Eroare BD =(", e);
          	    } 
            // abia acum trimitem
            String tod = "";
            String tos = "";
            String toa = "";
            String nume = "";
            String prenume = "";
            String motivv = "";
            int tipp = -1;
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
       	         PreparedStatement stmt = connection.prepareStatement("select ang.nume as nume_ang, ang.prenume as prenume_ang, ang.tip as tip, ang.email as email_ang, sef.email as email_sef, dir.email as email_dir from useri as ang join useri as sef on ang.id_dep = sef.id_dep and sef.tip = 3 join useri as dir on ang.id_dep = dir.id_dep and dir.tip = 0 where ang.id = ?;"
       	         		+ "")) {
       	        stmt.setInt(1, uid);
       	        
       	        ResultSet rs = stmt.executeQuery();
       	        if (rs.next()) {
       	            tos = rs.getString("email_sef");
       	            toa = rs.getString("email_ang");
       	            tod = rs.getString("email_dir");
       	            nume = rs.getString("nume_ang");
       	            prenume = rs.getString("prenume_ang");
       	            tipp = rs.getInt("tip");
       	        }
       	    } catch (SQLException e) {
       	        throw new ServletException("Eroare BD =(", e);
       	    } 
            
	           // trimit confirmare stergere la angajat 
	    	    String subject1 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message11 = "<h1>Ne pare rau sa venim cu asemnea vesti, caci... &#x1F614; </h1>"; 
	    	    String message12 = "<h2>Tocmai ati sters cu succes un concediu, mai exact cel din data de " + data 
	    	    		+ "</h2>";
	    	    String message13 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
	    	    String message14 = "<p><b>Inceput:</b> " + starto + "<br> <b>Final: </b> " + endo + "<br><b>Locatie:</b> " + loco + "<br><b> Motiv: </b>" + motivo + "<br><b>Tip concediu: </b>" + motivvo + "<br><b>Durata: </b>" + durato + " zile<br></p>";
	    	    String message17 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
	    	    		+ " </p>";
	    	    String message16 = "<br><p>Nu uitati ca puteti oricand sa programati un nou concediu in locul acestuia! &#x2728;\r\n"
	    	    		+ " </p>";
	    	    String message1 = message11 + message12 + message13 + message14 + message16 + message17 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	   
	    	    try {
	    	        sender.send(subject1, message1, "liviaaamp@gmail.com", toa);
	    	       
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	       
	    	    }  
            
            if (tipp != 3 || tipp != 0) {
            	// anunt seful ca cineva si-a sters un concediu
            	
	    	    String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message21 = "<h1>Ultimile noutati </h1>"; 
	    	    String message22 = "<h2>Angajatul " + nume + " " + prenume + " tocmai a sters cu succes un concediu, mai exact unul din data de " + data
	    	    		+ "</h2>";
	    	    String message23 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
	    	    String message24 = "<p><b>Inceput:</b> " + starto + "<br> <b>Final: </b> " + endo + "<br><b>Locatie:</b> " + loco + "<br><b> Motiv: </b>" + motivo + "<br><b>Tip concediu: </b>" + motivvo + "<br><b>Durata: </b>" + durato + " zile<br></p>";
	    	    String message27 = "<br><p>Va dorim toate cele bune! &#x1F607; \r\n"
	    	    		+ " </p>";
	    	    String message26 = "<p>Din pacate nu se stiu motivele pentru care a facut aceasta. Poate a intervenit ceva/poate ceva nu a mers bine. <br> In schimb, le putem veni in ajutor cu sustinere, recomandari, sfaturi. &#x1F609;\r\n"
	    	    		+ " Doar suntem o familie &#x1F917;\r\n"
	    	    		+ ""
	    	    		+ " </p>";
	    	    String message2 = message21 + message22 + message23 + message24 + message26 + message27 + "<br><b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea &#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	    try {
	    	        sender.send(subject2, message2, "liviaaamp@gmail.com", tos);
	    	        
	    	       
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	       
	    	    }  
            }
            if (tipp == 3) {
            	// hai sa anuntam si conducerea cea mare despre sef ca de ce nu
            	String subject2 = "\uD83D\uDEA8 Aveti o notificare \uD83D\uDEA8";
	    	    String message21 = "<h1>Ultimile noutati </h1>"; 
	    	    String message22 = "<h2>Angajatul " + nume + " " + prenume + " tocmai a sters cu succes un concediu, mai exact unul din data de " + data
	    	    		+ "</h2>";
	    	    String message23 = "<h3>&#x1F4DD;Detalii despre vechiul concediu:</h3>";
	    	    String message24 = "<p><b>Inceput:</b> " + starto + "<br> <b>Final: </b> " + endo + "<br><b>Locatie:</b> " + loco + "<br><b> Motiv: </b>" + motivo + "<br><b>Tip concediu: </b>" + motivvo + "<br><b>Durata: </b>" + durato + " zile<br></p>";
	    	    String message27 = "<p>Va dorim toate cele bune! &#x1F607; \r\n"
	    	    		+ " </p>";
	    	    String message26 = "<p>Din pacate nu se stiu motivele pentru care a facut aceasta. Poate a intervenit ceva/poate ceva nu a mers bine. <br> In schimb, le putem veni in ajutor cu sustinere, recomandari, sfaturi. &#x1F609;\r\n"
	    	    		+ " Doar suntem o familie &#x1F917;\r\n"
	    	    		+ ""
	    	    		+ " </p>";
	    	    String message2 = message21 + message22 + message23 + message24 + message26 + message27 + "<b><i>&#x2757;Mesaj trimis automat.<br> Semnat, <br> Conducerea&#x1F642;\r\n"
	    	    		+ "</i></b>";
	    	   
	    	    try {
	    	        sender.send(subject2, message2, "liviaaamp@gmail.com", tod);
	    	        
	    	       
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	       
	    	    }  
            }
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Stergere cu succes!');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
        } catch (Exception e) {
        	response.setContentType("text/html;charset=UTF-8");
		    PrintWriter out = response.getWriter();
		    out.println("<script type='text/javascript'>");
		    out.println("alert('Nu s-a putut sterge concediul din motive necunoscute.');");
		    out.println("window.location.href = 'actiuni.jsp';");
		    out.println("</script>");
		    out.close();
			e.printStackTrace();
        }
	}

}
