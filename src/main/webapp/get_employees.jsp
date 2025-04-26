<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.util.*" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String deptId = request.getParameter("deptId");
    List<Map<String, Object>> employees = new ArrayList<>();
    
    if (deptId != null && !deptId.isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            String query = "SELECT id, nume, prenume FROM useri WHERE id_dep = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, deptId);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> emp = new HashMap<>();
                emp.put("id", rs.getInt("id"));
                emp.put("nume", rs.getString("nume"));
                emp.put("prenume", rs.getString("prenume"));
                employees.add(emp);
            }
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
    }
    
    JSONArray jsonArray = new JSONArray(employees);
    out.print(jsonArray.toString());
    out.flush();
%>