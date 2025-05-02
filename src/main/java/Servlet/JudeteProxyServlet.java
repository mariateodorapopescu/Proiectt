package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

public class JudeteProxyServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Create a JSON array with Romanian counties
        JSONArray countiesArray = new JSONArray();
        
        // Add all Romanian counties with their codes
        addCounty(countiesArray, "ALBA", "AB");
        addCounty(countiesArray, "ARAD", "AR");
        addCounty(countiesArray, "ARGEȘ", "AG");
        addCounty(countiesArray, "BACĂU", "BC");
        addCounty(countiesArray, "BIHOR", "BH");
        addCounty(countiesArray, "BISTRIȚA-NĂSĂUD", "BN");
        addCounty(countiesArray, "BOTOȘANI", "BT");
        addCounty(countiesArray, "BRĂILA", "BR");
        addCounty(countiesArray, "BRAȘOV", "BV");
        addCounty(countiesArray, "BUCUREȘTI", "B");
        addCounty(countiesArray, "BUZĂU", "BZ");
        addCounty(countiesArray, "CĂLĂRAȘI", "CL");
        addCounty(countiesArray, "CARAȘ-SEVERIN", "CS");
        addCounty(countiesArray, "CLUJ", "CJ");
        addCounty(countiesArray, "CONSTANȚA", "CT");
        addCounty(countiesArray, "COVASNA", "CV");
        addCounty(countiesArray, "DÂMBOVIȚA", "DB");
        addCounty(countiesArray, "DOLJ", "DJ");
        addCounty(countiesArray, "GALAȚI", "GL");
        addCounty(countiesArray, "GIURGIU", "GR");
        addCounty(countiesArray, "GORJ", "GJ");
        addCounty(countiesArray, "HARGHITA", "HR");
        addCounty(countiesArray, "HUNEDOARA", "HD");
        addCounty(countiesArray, "IALOMIȚA", "IL");
        addCounty(countiesArray, "IAȘI", "IS");
        addCounty(countiesArray, "ILFOV", "IF");
        addCounty(countiesArray, "MARAMUREȘ", "MM");
        addCounty(countiesArray, "MEHEDINȚI", "MH");
        addCounty(countiesArray, "MUREȘ", "MS");
        addCounty(countiesArray, "NEAMȚ", "NT");
        addCounty(countiesArray, "OLT", "OT");
        addCounty(countiesArray, "PRAHOVA", "PH");
        addCounty(countiesArray, "SĂLAJ", "SJ");
        addCounty(countiesArray, "SATU MARE", "SM");
        addCounty(countiesArray, "SIBIU", "SB");
        addCounty(countiesArray, "SUCEAVA", "SV");
        addCounty(countiesArray, "TELEORMAN", "TR");
        addCounty(countiesArray, "TIMIȘ", "TM");
        addCounty(countiesArray, "TULCEA", "TL");
        addCounty(countiesArray, "VÂLCEA", "VL");
        addCounty(countiesArray, "VASLUI", "VS");
        addCounty(countiesArray, "VRANCEA", "VN");
        
        // Return the JSON array
        out.print(countiesArray.toString());
    }
    
    private void addCounty(JSONArray array, String name, String code) {
        JSONObject county = new JSONObject();
        county.put("nume", name);
        county.put("auto", code);
        array.put(county);
    }
}