//package Servlet;
//// importare biblioteci
//import DAO.*;
//import bean.*;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import mail.MailAsincron;
//
//import java.io.IOException;
//import java.io.PrintWriter;
//
///**
// * Implementarea servlet-ului ce se ocupa de stergerea unui concediu
// */
//public class DelConServlet extends HttpServlet {
//	private static final long serialVersionUID = 1L;
//       
//    /**
//     * @see HttpServlet#HttpServlet()
//     */
//    public DelConServlet() {
//        super();
//    }
//    // DAO pentru baza de date
//    private DelConDao concediu;
//    /**
//     * initializare DAO
//     */
//    public void init() {
//        concediu = new DelConDao();
//    }
//    
//	/**
//	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		doPost(request, response);
//	}
//
//	/**
//	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//	// declarare si initializare variabile
//		int id = Integer.valueOf(request.getParameter("idcon"));
//		String inceput = request.getParameter("start");
//		String sfarsit = request.getParameter("end");
//    	String motiv = request.getParameter("motiv");
//    	String locatie = request.getParameter("locatie");
//    	
//        Concediu concediul = new Concediu();
//        
//        // setare date de clasa a obiectului concediu
//        concediul.setId(id);
//        concediul.setInceput(inceput);
//        concediul.setSfarsit(sfarsit);
//        concediul.setMotiv(motiv);
//        concediul.setLocatie(locatie);
//        
//        try {
//            concediu.stergere(concediul);
//           
//            // trimitere asincrona
//            jakarta.servlet.AsyncContext asyncContext = request.startAsync();
//             
//            asyncContext.start(() -> {
//                try {
//                	// am facut o clasa/un obiect separat ce trimite mailuri, separat de un mail sender, ci efectiv ceva ce pregatste un email
//                    MailAsincron.send9(id);
//                    asyncContext.complete();  // Completarea actiunii asincrone
//                } catch (Exception e) {
//                    e.printStackTrace();  // in caz de eroare, afisez in concola serverului sa vad de ce + redirectare la pagina de adaugare/modificare concediu + alerta
//                    asyncContext.complete();  // Context asincron finalizat indiferent de situatie
//                    response.setContentType("text/html;charset=UTF-8");
//        	        PrintWriter out = null;
//					try {
//						out = response.getWriter();
//					} catch (IOException e1) {
//						// TODO Auto-generated catch block
//						e1.printStackTrace();
//					}
//        	        out.println("<script type='text/javascript'>");
//        	        out.println("alert('eroare din cauze necunoscute!');");
//        	        out.println("window.location.href = 'actiuni.jsp';");
//        	        out.println("</script>");
//        	        out.close();
//        	        return; 
//                    
//                }
//            });
//            
//            response.setContentType("text/html;charset=UTF-8");
//            PrintWriter out = response.getWriter();
//		    out.println("<script type='text/javascript'>");
//		    out.println("alert('Stergere cu succes!');");
//		    out.println("window.location.href = 'actiuni.jsp';");
//		    out.println("</script>");
//		    out.close();
//        } catch (Exception e) {
//        	response.setContentType("text/html;charset=UTF-8");
//		    PrintWriter out = response.getWriter();
//		    out.println("<script type='text/javascript'>");
//		    out.println("alert('Nu s-a putut sterge concediul din motive necunoscute.');");
//		    out.println("window.location.href = 'actiuni.jsp';");
//		    out.println("</script>");
//		    out.close();
//			e.printStackTrace();
//        }
//	}
//
package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.MyUser;

public class DelConServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check session
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("logout");
            return;
        }

        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("logout");
            return;
        }

        // Get the leave request ID to delete
        String idconParam = request.getParameter("idcon");
        if (idconParam == null || idconParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID-ul concediului lipsește");
            return;
        }

        int concediuId;
        try {
            concediuId = Integer.parseInt(idconParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID-ul concediului este invalid");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection connection = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
                
                // First, verify that the user owns this leave request
                String verifyQuery = "SELECT id_ang FROM concedii WHERE id = ?";
                try (PreparedStatement verifyStmt = connection.prepareStatement(verifyQuery)) {
                    verifyStmt.setInt(1, concediuId);
                    var rs = verifyStmt.executeQuery();
                    
                    if (!rs.next()) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Concediul nu a fost găsit");
                        return;
                    }
                    
                    int ownerId = rs.getInt("id_ang");
                    if (ownerId != currentUser.getId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                            "Nu aveți permisiunea să ștergeți acest concediu");
                        return;
                    }
                }
                
                // Delete related location records first (if they exist)
                String deleteLocationsQuery = "DELETE FROM locatii_concedii WHERE id_concediu = ?";
                try (PreparedStatement deleteLocStmt = connection.prepareStatement(deleteLocationsQuery)) {
                    deleteLocStmt.setInt(1, concediuId);
                    int locationsDeleted = deleteLocStmt.executeUpdate();
                    System.out.println("Deleted " + locationsDeleted + " location records for concediu " + concediuId);
                }
                
                // Delete the main leave request
                String deleteQuery = "DELETE FROM concedii WHERE id = ?";
                try (PreparedStatement deleteStmt = connection.prepareStatement(deleteQuery)) {
                    deleteStmt.setInt(1, concediuId);
                    int rowsAffected = deleteStmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        System.out.println("Successfully deleted concediu with ID: " + concediuId);
                        
                        // Redirect back to the leave requests page with success message
                        response.sendRedirect("concediinoisef.jsp?pag=1&deleted=success");
                    } else {
                        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                            "Nu s-a putut șterge concediul");
                    }
                }
                
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Eroare de configurare a bazei de date");
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Eroare la ștergerea concediului: " + e.getMessage());
        }
    }
}
//}
