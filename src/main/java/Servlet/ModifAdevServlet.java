package Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
 * Servlet pentru modificarea adeverințelor
 */
public class ModifAdevServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdaugaAdeverintaDAO adeverintaDAO;
    
    // Constante pentru configurarea conexiunii
    private static final String URL = "jdbc:mysql://localhost:3306/test";
    private static final String USER = "root";
    private static final String PASSWORD = "student";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    /**
     * Constructor
     */
    public ModifAdevServlet() {
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
     * Metoda GET - folosită pentru a afișa datele adeverinței
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
        
        // Obține ID-ul adeverinței din parametri
        int idAdeverinta;
        try {
            idAdeverinta = Integer.parseInt(request.getParameter("idadev"));
        } catch (NumberFormatException e) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('ID adeverință invalid!');");
            out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
            out.println("</script>");
            out.close();
            return;
        }
        
        // Verifică dacă adeverința există și dacă utilizatorul are dreptul să o modifice
        Connection conn = null;
        
        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            
            // Verifică existența adeverinței și permisiunile
            String sqlVerificare = "SELECT a.*, u.tip AS tip_user FROM adeverinte a JOIN useri u ON a.id_ang = u.id WHERE a.id = ?";
            try (PreparedStatement verificareStmt = conn.prepareStatement(sqlVerificare)) {
                verificareStmt.setInt(1, idAdeverinta);
                ResultSet rs = verificareStmt.executeQuery();
                
                if (!rs.next()) {
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Adeverința nu există!');");
                    out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                    out.println("</script>");
                    out.close();
                    return;
                }
                
                int idAngajat = rs.getInt("id_ang");
                int status = rs.getInt("status");
                int tipAngajat = rs.getInt("tip_user");
                int tip = rs.getInt("tip");
                
                // Obține valorile din ambele câmpuri
                String motiv = rs.getString("motiv");
                String pentruServi = rs.getString("pentru_servi");
                
                // Folosește valoarea non-null
                if ((motiv == null || motiv.trim().isEmpty()) && pentruServi != null && !pentruServi.trim().isEmpty()) {
                    motiv = pentruServi;
                }
                
                // Verifică permisiunile
                int currentUserId = currentUser.getId();
                int userType = currentUser.getTip();
                
                boolean hasPermission = false;
                
                // Utilizatorul poate modifica adeverințele proprii doar dacă sunt neaprobate (status 0)
                if (idAngajat == currentUserId && status == 0) {
                    hasPermission = true;
                }
                
                // Șeful (tip=3) poate modifica adeverințele din departamentul său
                boolean isSef = userType == 3 || (userType >= 10 && userType <= 15);
                if (isSef && status <= 1) {
                    // Verifică dacă angajatul este în același departament
                    String sqlDep = "SELECT 1 FROM useri WHERE id = ? AND id_dep = (SELECT id_dep FROM useri WHERE id = ?)";
                    try (PreparedStatement depStmt = conn.prepareStatement(sqlDep)) {
                        depStmt.setInt(1, idAngajat);
                        depStmt.setInt(2, currentUserId);
                        ResultSet rsDep = depStmt.executeQuery();
                        if (rsDep.next()) {
                            hasPermission = true;
                        }
                    }
                }
                
                // Directorul (tip=0) poate modifica orice adeverință
                boolean isDirector = userType == 0 || userType == 4 || userType > 15;
                if (isDirector) {
                    hasPermission = true;
                }
                
                if (!hasPermission) {
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu aveți permisiunea de a modifica această adeverință!');");
                    out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                    out.println("</script>");
                    out.close();
                    return;
                }
                
                // Adeverința există și utilizatorul are permisiuni, redirecționează către pagina de modificare
                // Adaugă datele adeverinței în sesiune pentru a fi folosite în pagina de modificare
                Adeverinta adeverinta = new Adeverinta();
                adeverinta.setId(idAdeverinta);
                adeverinta.setIdAngajat(idAngajat);
                adeverinta.setTip(tip);
                adeverinta.setMotiv(motiv);
                adeverinta.setStatus(status);
                
                sesiune.setAttribute("adeverintaDeMod", adeverinta);
                
                response.sendRedirect("modivadev.jsp");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la verificarea adeverinței: " + e.getMessage() + "');");
            out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
            out.println("</script>");
            out.close();
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Metoda POST - folosită pentru a salva modificările adeverinței
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
        
        // Extrage parametrii din formular
        int idAdeverinta;
        int tip;
        String motiv;
        
        try {
            idAdeverinta = Integer.parseInt(request.getParameter("idadev"));
            tip = Integer.parseInt(request.getParameter("tip"));
            motiv = request.getParameter("motiv");
            System.out.println(idAdeverinta + " " + tip + " " + motiv);
            // Validare date
            if (motiv == null || motiv.trim().isEmpty()) {
                throw new IllegalArgumentException("Motivul nu poate fi gol!");
            }
        } catch (NumberFormatException e) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Parametri invalizi!');");
            out.println("window.location.href = 'modivadev.jsp';");
            out.println("</script>");
            out.close();
            return;
        } catch (IllegalArgumentException e) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('" + e.getMessage() + "');");
            out.println("window.location.href = 'modivadev.jsp';");
            out.println("</script>");
            out.close();
            return;
        }
        
        Connection conn = null;
        PreparedStatement verificareStmt = null;
        PreparedStatement modifStmt = null;
        
        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            conn.setAutoCommit(false); // Începe tranzacția
            
            // Verifică din nou permisiunile (în caz că ceva s-a schimbat între timp)
            String sqlVerificare = "SELECT a.id_ang, a.status FROM adeverinte a WHERE a.id = ?";
            verificareStmt = conn.prepareStatement(sqlVerificare);
            verificareStmt.setInt(1, idAdeverinta);
            ResultSet rs = verificareStmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința nu există sau a fost ștearsă!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
                return;
            }
            
            int idAngajat = rs.getInt("id_ang");
            int status = rs.getInt("status");
            
            int currentUserId = currentUser.getId();
            int userType = currentUser.getTip();
            
            boolean hasPermission = false;
            
            // Utilizatorul poate modifica adeverințele proprii doar dacă sunt neaprobate (status 0)
            if (idAngajat == currentUserId && status == 0) {
                hasPermission = true;
            }
            
            // Șeful (tip=3) poate modifica adeverințele din departamentul său
            boolean isSef = userType == 3 || (userType >= 10 && userType <= 15);
            if (isSef && status <= 1) {
                // Verifică dacă angajatul este în același departament
                String sqlDep = "SELECT 1 FROM useri WHERE id = ? AND id_dep = (SELECT id_dep FROM useri WHERE id = ?)";
                try (PreparedStatement depStmt = conn.prepareStatement(sqlDep)) {
                    depStmt.setInt(1, idAngajat);
                    depStmt.setInt(2, currentUserId);
                    ResultSet rsDep = depStmt.executeQuery();
                    if (rsDep.next()) {
                        hasPermission = true;
                    }
                }
            }
            
            // Directorul (tip=0) poate modifica orice adeverință
            boolean isDirector = userType == 0 || userType == 4 || userType > 15;
            if (isDirector) {
                hasPermission = true;
            }
            
            if (!hasPermission) {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Nu aveți permisiunea de a modifica această adeverință!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
                return;
            }
            
            // Modifică adeverința - actualizează ambele câmpuri motiv și pentru_servi
            String sqlModificare = "UPDATE adeverinte SET tip = ?, motiv = ?, pentru_servi = ?, modif = CURDATE() WHERE id = ?";
            modifStmt = conn.prepareStatement(sqlModificare);
            modifStmt.setInt(1, tip);
            modifStmt.setString(2, motiv);
            modifStmt.setString(3, motiv); // Asigură actualizarea câmpului pentru_servi
            modifStmt.setInt(4, idAdeverinta);
            
            int rezultat = modifStmt.executeUpdate();
            
            if (rezultat > 0) {
                conn.commit(); // Confirmă tranzacția
                
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Adeverința a fost modificată cu succes!');");
                out.println("window.location.href = 'adeverintenoiuser.jsp?pag=1';");
                out.println("</script>");
                out.close();
            } else {
                conn.rollback();
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script type='text/javascript'>");
                out.println("alert('Nu s-a putut modifica adeverința!');");
                out.println("window.location.href = 'modivadev.jsp';");
                out.println("</script>");
                out.close();
            }
            
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la modificarea adeverinței: " + e.getMessage() + "');");
            out.println("window.location.href = 'modivadev.jsp';");
            out.println("</script>");
            out.close();
        } finally {
            try {
                if (verificareStmt != null) verificareStmt.close();
                if (modifStmt != null) modifStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Resetează autocommit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}