package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.MyUser;

public class GetAdeverinteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            json.put("success", false);
            json.put("message", "Sesiune invalidă");
            out.print(json.toString());
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userTip = currentUser.getTip();
        
        // Verificare permisiuni - doar director și șefi de departament pot vedea cererile
        if (userTip != 0 && userTip != 3) {
            json.put("success", false);
            json.put("message", "Nu aveți permisiuni");
            out.print(json.toString());
            return;
        }
        
        // Parametri pentru paginare
        int page = 1;
        int itemsPerPage = 10;
        
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
            
            if (request.getParameter("itemsPerPage") != null) {
                itemsPerPage = Integer.parseInt(request.getParameter("itemsPerPage"));
            }
        } catch (NumberFormatException e) {
            // Folosim valorile implicite în caz de eroare
            page = 1;
            itemsPerPage = 10;
        }
        
        // Calculăm offset-ul pentru SQL
        int offset = (page - 1) * itemsPerPage;
        
        // Departamentul pentru șefi
        Integer departamentId = null;
        if (userTip == 3 && request.getParameter("departament") != null) {
            try {
                departamentId = Integer.parseInt(request.getParameter("departament"));
            } catch (NumberFormatException e) {
                // Ignorăm valoarea incorectă
            }
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                
                // Construim query-ul în funcție de tipul utilizatorului
                StringBuilder sqlCount = new StringBuilder("SELECT COUNT(*) as total FROM adeverinte a");
                StringBuilder sql = new StringBuilder(
                        "SELECT a.id, a.id_ang, a.tip, a.pentru_servi, a.status, a.creare, " +
                        "u.nume, u.prenume, d.nume_dep, t.denumire as tip_denumire, s.nume_status " +
                        "FROM adeverinte a " +
                        "JOIN useri u ON a.id_ang = u.id " +
                        "JOIN departament d ON u.id_dep = d.id_dep " +
                        "JOIN tip_adev t ON a.tip = t.id " +
                        "JOIN statusuri s ON a.status = s.status "
                );
                
                // Adăugăm condiții în funcție de tipul utilizatorului
                if (userTip == 3) {
                    // Șef de departament vede doar cererile din departamentul său cu status 0 (neaprobate)
                    sqlCount.append(" JOIN useri u ON a.id_ang = u.id WHERE u.id_dep = ? AND a.status = 0");
                    sql.append("WHERE u.id_dep = ? AND a.status = 0 ");
                } else if (userTip == 0) {
                    // Directorul vede doar cererile aprobate de șefi (status 1)
                    sqlCount.append(" WHERE a.status = 1");
                    sql.append("WHERE a.status = 1 ");
                }
                
                // Adăugăm ordinea și limitarea
                sql.append("ORDER BY a.creare DESC LIMIT ? OFFSET ?");
                
                // Obținem numărul total de înregistrări
                int totalItems = 0;
                try (PreparedStatement countStmt = conn.prepareStatement(sqlCount.toString())) {
                    if (userTip == 3) {
                        countStmt.setInt(1, departamentId != null ? departamentId : currentUser.getDepartament());
                    }
                    
                    try (ResultSet rsCount = countStmt.executeQuery()) {
                        if (rsCount.next()) {
                            totalItems = rsCount.getInt("total");
                        }
                    }
                }
                
                // Obținem înregistrările pentru pagina curentă
                JSONArray adeverinteArray = new JSONArray();
                try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
                    int paramIndex = 1;
                    
                    if (userTip == 3) {
                        stmt.setInt(paramIndex++, departamentId != null ? departamentId : currentUser.getDepartament());
                    }
                    
                    stmt.setInt(paramIndex++, itemsPerPage);
                    stmt.setInt(paramIndex++, offset);
                    
                    try (ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            JSONObject adeverinta = new JSONObject();
                            
                            adeverinta.put("id", rs.getInt("id"));
                            adeverinta.put("idAngajat", rs.getInt("id_ang"));
                            adeverinta.put("numeAngajat", rs.getString("nume") + " " + rs.getString("prenume"));
                            adeverinta.put("departament", rs.getString("nume_dep"));
                            adeverinta.put("tipAdeverinta", rs.getString("tip_denumire"));
                            adeverinta.put("motiv", rs.getString("pentru_servi"));
                            adeverinta.put("status", rs.getInt("status"));
                            adeverinta.put("statusText", rs.getString("nume_status"));
                            adeverinta.put("dataCerere", rs.getDate("creare").toString());
                            
                            adeverinteArray.put(adeverinta);
                        }
                    }
                }
                
                // Construim răspunsul
                json.put("success", true);
                json.put("adeverinte", adeverinteArray);
                json.put("totalItems", totalItems);
                json.put("page", page);
                json.put("itemsPerPage", itemsPerPage);
                json.put("totalPages", (int) Math.ceil((double) totalItems / itemsPerPage));
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la încărcare: " + e.getMessage());
        }
        
        out.print(json.toString());
        out.flush();
    }
}