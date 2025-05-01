package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mail.MailAsincron;
import bean.MyUser;
import bean.Adeverinta;
import DAO.AdaugaAdeverintaDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Servlet pentru adăugarea adeverințelor
 */
public class AddAdevServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdaugaAdeverintaDAO adeverintaDAO;
    
    // Constante pentru conexiunea la baza de date
    private static final String URL = "jdbc:mysql://localhost:3306/test";
    private static final String USER = "root";
    private static final String PASSWORD = "student";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    /**
     * Constructor
     */
    public AddAdevServlet() {
        super();
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Inițializare servlet
     */
    public void init() {
        adeverintaDAO = new AdaugaAdeverintaDAO();
    }
    
    /**
     * Metoda GET - nu este implementată, doar afișează un mesaj
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().append("Nu se poate face GET pe acest servlet.");
    }
    
    /**
     * Metoda POST - procesează adăugarea adeverințelor
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verificare sesiune
        HttpSession sesiune = request.getSession(false);
        if (sesiune == null) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Nu există sesiune activă!');");
            out.println("window.location.href = 'login.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        MyUser currentUser = (MyUser) sesiune.getAttribute("currentUser");
        if (currentUser == null) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("window.location.href = 'login.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        // Extragere date din formular
        int idAngajat = Integer.valueOf(request.getParameter("userId"));
        int tip = Integer.valueOf(request.getParameter("tip"));
        String motiv = request.getParameter("motiv");
        
        // Verificare date
        if (motiv == null || motiv.trim().isEmpty()) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Motivul nu poate fi gol!');");
            out.println("window.location.href = 'addadev.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        try {
            // Verifică tipul utilizatorului și setează statusul adeverinței corespunzător
            int tipAngajat = determinaTipAngajat(idAngajat);
            int status = 0; // Status implicit: neaprobat
            
            // Dacă utilizatorul este șef (tip = 3), director (tip = 4) sau alt rol superior (tip >= 9),
            // statusul va fi direct 1 (aprobat de șef)
            if (tipAngajat == 3 || tipAngajat == 4 || tipAngajat >= 9) {
                status = 1; // Aprobat de șef
            }
            
            // Creare obiect Adeverinta
            Adeverinta adeverinta = new Adeverinta();
            adeverinta.setIdAngajat(idAngajat);
            adeverinta.setTip(tip);
            adeverinta.setMentiuni(motiv);
            adeverinta.setStatus(status); // Status stabilit în funcție de tipul angajatului
            
            // Adăugare în baza de date
            int result = adeverintaDAO.incarca(adeverinta);
            
            if (result > 0) {
                // Determinare șef departament pentru notificare doar dacă statusul este 0
                int idSef = -1;
                if (status == 0) {
                    idSef = determinaSef(idAngajat);
                }
                
                // Trimitere răspuns către client
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                if (status == 1) {
                    out.println("alert('Adeverința a fost adăugată și aprobată automat!');");
                } else {
                    out.println("alert('Adeverința a fost adăugată cu succes și așteaptă aprobarea!');");
                }
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
                
                // Trimitere email în mod asincron doar dacă e necesar (statusul e 0)
                if (status == 0 && idSef != -1) {
                    final int idSefFinal = idSef;
                    Thread mailThread = new Thread(() -> {
                        try {
                            // Se trimite email atât șefului cât și solicitantului
                            MailAsincron.trimitereNotificareAdeverintaNoua(idAngajat, idSefFinal, tip, motiv);
                        } catch (Exception e) {
                            e.printStackTrace();
                            System.out.println("Eroare la trimiterea email-ului: " + e.getMessage());
                        }
                    });
                    mailThread.start();
                }
            } else {
                throw new SQLException("Nu s-a putut adăuga adeverința în baza de date");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la adăugarea adeverinței: " + e.getMessage() + "');");
            out.println("window.location.href = 'addadev.jsp';");
            out.println("</script>");
            out.close();
        }
    }
    
    /**
     * Determină tipul unui angajat
     * 
     * @param idAngajat ID-ul angajatului
     * @return Tipul angajatului sau -1 dacă nu este găsit
     */
    private int determinaTipAngajat(int idAngajat) {
        try (Connection conexiune = DriverManager.getConnection(URL, USER, PASSWORD)) {
            String sql = "SELECT tip FROM useri WHERE id = ?";
            try (PreparedStatement ps = conexiune.prepareStatement(sql)) {
                ps.setInt(1, idAngajat);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("tip");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Nu am găsit angajatul
    }
    
    /**
     * Determină ID-ul șefului departamentului pentru un angajat
     * 
     * @param idAngajat ID-ul angajatului
     * @return ID-ul șefului departamentului sau -1 dacă nu este găsit
     */
    private int determinaSef(int idAngajat) {
        try (Connection conexiune = DriverManager.getConnection(URL, USER, PASSWORD)) {
            // Mai întâi aflăm departamentul angajatului
            String sqlDepartament = "SELECT id_dep FROM useri WHERE id = ?";
            try (PreparedStatement psDepartament = conexiune.prepareStatement(sqlDepartament)) {
                psDepartament.setInt(1, idAngajat);
                try (ResultSet rsDepartament = psDepartament.executeQuery()) {
                    if (rsDepartament.next()) {
                        int idDepartament = rsDepartament.getInt("id_dep");
                        
                        // Apoi căutăm șeful departamentului (tip = 3)
                        String sqlSef = "SELECT id FROM useri WHERE id_dep = ? AND tip = 3";
                        try (PreparedStatement psSef = conexiune.prepareStatement(sqlSef)) {
                            psSef.setInt(1, idDepartament);
                            try (ResultSet rsSef = psSef.executeQuery()) {
                                if (rsSef.next()) {
                                    return rsSef.getInt("id");
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Nu am găsit șeful
    }
}