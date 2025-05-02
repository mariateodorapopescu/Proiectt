package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

public class LocalitatiProxyServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private static final Map<String, String[]> CITIES_BY_COUNTY = new HashMap<>();
    
    static {
        // Initialize cities for each county
        CITIES_BY_COUNTY.put("AB", new String[]{"Alba Iulia", "Aiud", "Blaj", "Câmpeni", "Cugir", "Ocna Mureș", "Sebeș", "Teiuș", "Zlatna"});
        CITIES_BY_COUNTY.put("AR", new String[]{"Arad", "Chișineu-Criș", "Curtici", "Ineu", "Lipova", "Nădlac", "Pâncota", "Sebiș"});
        CITIES_BY_COUNTY.put("AG", new String[]{"Pitești", "Câmpulung", "Curtea de Argeș", "Costești", "Mioveni", "Ștefănești", "Topoloveni"});
        CITIES_BY_COUNTY.put("BC", new String[]{"Bacău", "Buhuși", "Comănești", "Dărmănești", "Moinești", "Onești", "Slănic-Moldova", "Târgu Ocna"});
        CITIES_BY_COUNTY.put("BH", new String[]{"Oradea", "Aleșd", "Beiuș", "Marghita", "Nucet", "Salonta", "Săcueni", "Ștei", "Valea lui Mihai", "Vașcău"});
        CITIES_BY_COUNTY.put("BN", new String[]{"Bistrița", "Beclean", "Năsăud", "Sângeorz-Băi"});
        CITIES_BY_COUNTY.put("BT", new String[]{"Botoșani", "Bucecea", "Darabani", "Dorohoi", "Flămânzi", "Săveni", "Ștefănești"});
        CITIES_BY_COUNTY.put("BR", new String[]{"Brăila", "Făurei", "Ianca", "Însurăței"});
        CITIES_BY_COUNTY.put("BV", new String[]{"Brașov", "Codlea", "Făgăraș", "Ghimbav", "Predeal", "Râșnov", "Rupea", "Săcele", "Victoria", "Zărnești"});
        CITIES_BY_COUNTY.put("B", new String[]{"București", "Sector 1", "Sector 2", "Sector 3", "Sector 4", "Sector 5", "Sector 6"});
        CITIES_BY_COUNTY.put("BZ", new String[]{"Buzău", "Nehoiu", "Pătârlagele", "Pogoanele", "Râmnicu Sărat"});
        CITIES_BY_COUNTY.put("CL", new String[]{"Călărași", "Budești", "Fundulea", "Lehliu Gară", "Oltenița"});
        CITIES_BY_COUNTY.put("CS", new String[]{"Reșița", "Anina", "Băile Herculane", "Bocșa", "Caransebeș", "Moldova Nouă", "Oravița", "Oțelu Roșu"});
        CITIES_BY_COUNTY.put("CJ", new String[]{"Cluj-Napoca", "Câmpia Turzii", "Dej", "Gherla", "Huedin", "Turda"});
        CITIES_BY_COUNTY.put("CT", new String[]{"Constanța", "Cernavodă", "Eforie", "Hârșova", "Mangalia", "Medgidia", "Murfatlar", "Năvodari", "Negru Vodă", "Ovidiu", "Techirghiol"});
        CITIES_BY_COUNTY.put("CV", new String[]{"Sfântu Gheorghe", "Baraolt", "Covasna", "Întorsura Buzăului", "Târgu Secuiesc"});
        CITIES_BY_COUNTY.put("DB", new String[]{"Târgoviște", "Fieni", "Găești", "Moreni", "Pucioasa", "Răcari", "Titu"});
        CITIES_BY_COUNTY.put("DJ", new String[]{"Craiova", "Băilești", "Bechet", "Calafat", "Dăbuleni", "Filiași", "Segarcea"});
        CITIES_BY_COUNTY.put("GL", new String[]{"Galați", "Berești", "Târgu Bujor", "Tecuci"});
        CITIES_BY_COUNTY.put("GR", new String[]{"Giurgiu", "Bolintin-Vale", "Mihăilești"});
        CITIES_BY_COUNTY.put("GJ", new String[]{"Târgu Jiu", "Bumbești-Jiu", "Motru", "Novaci", "Rovinari", "Târgu Cărbunești", "Tismana", "Turceni", "Țicleni"});
        CITIES_BY_COUNTY.put("HR", new String[]{"Miercurea Ciuc", "Băile Tușnad", "Bălan", "Borsec", "Cristuru Secuiesc", "Gheorgheni", "Odorheiu Secuiesc", "Toplița", "Vlăhița"});
        CITIES_BY_COUNTY.put("HD", new String[]{"Deva", "Aninoasa", "Brad", "Călan", "Geoagiu", "Hațeg", "Hunedoara", "Lupeni", "Orăștie", "Petrila", "Petroșani", "Simeria", "Uricani", "Vulcan"});
        CITIES_BY_COUNTY.put("IL", new String[]{"Slobozia", "Amara", "Căzănești", "Fetești", "Fierbinți-Târg", "Țăndărei", "Urziceni"});
        CITIES_BY_COUNTY.put("IS", new String[]{"Iași", "Hârlău", "Pașcani", "Podu Iloaiei", "Târgu Frumos"});
        CITIES_BY_COUNTY.put("IF", new String[]{"Bragadiru", "Buftea", "Chitila", "Măgurele", "Otopeni", "Pantelimon", "Popești-Leordeni", "Voluntari"});
        CITIES_BY_COUNTY.put("MM", new String[]{"Baia Mare", "Baia Sprie", "Borșa", "Cavnic", "Dragomirești", "Săliștea de Sus", "Seini", "Sighetu Marmației", "Șomcuta Mare", "Tăuții-Măgherăuș", "Târgu Lăpuș", "Ulmeni", "Vișeu de Sus"});
        CITIES_BY_COUNTY.put("MH", new String[]{"Drobeta-Turnu Severin", "Baia de Aramă", "Orșova", "Strehaia", "Vânju Mare"});
        CITIES_BY_COUNTY.put("MS", new String[]{"Târgu Mureș", "Iernut", "Luduș", "Miercurea Nirajului", "Reghin", "Sângeorgiu de Pădure", "Sărmașu", "Sighișoara", "Sovata", "Târnăveni", "Ungheni"});
        CITIES_BY_COUNTY.put("NT", new String[]{"Piatra Neamț", "Bicaz", "Roznov", "Roman", "Târgu Neamț"});
        CITIES_BY_COUNTY.put("OT", new String[]{"Slatina", "Balș", "Corabia", "Drăgănești-Olt", "Piatra-Olt", "Potcoava", "Scornicești"});
        CITIES_BY_COUNTY.put("PH", new String[]{"Ploiești", "Azuga", "Băicoi", "Boldești-Scăeni", "Breaza", "Bușteni", "Câmpina", "Comarnic", "Mizil", "Plopeni", "Sinaia", "Slănic", "Urlați", "Vălenii de Munte"});
        CITIES_BY_COUNTY.put("SJ", new String[]{"Zalău", "Cehu Silvaniei", "Jibou", "Șimleu Silvaniei"});
        CITIES_BY_COUNTY.put("SM", new String[]{"Satu Mare", "Ardud", "Carei", "Livada", "Negrești-Oaș", "Tășnad"});
        CITIES_BY_COUNTY.put("SB", new String[]{"Sibiu", "Agnita", "Avrig", "Cisnădie", "Copșa Mică", "Dumbrăveni", "Miercurea Sibiului", "Ocna Sibiului", "Săliște", "Tălmaciu"});
        CITIES_BY_COUNTY.put("SV", new String[]{"Suceava", "Broșteni", "Cajvana", "Dolhasca", "Fălticeni", "Frasin", "Gura Humorului", "Liteni", "Milișăuți", "Rădăuți", "Salcea", "Siret", "Solca", "Vicovu de Sus"});
        CITIES_BY_COUNTY.put("TR", new String[]{"Alexandria", "Roșiorii de Vede", "Turnu Măgurele", "Videle", "Zimnicea"});
        CITIES_BY_COUNTY.put("TM", new String[]{"Timișoara", "Buziaș", "Ciacova", "Deta", "Făget", "Gătaia", "Jimbolia", "Lugoj", "Recaș", "Sânnicolau Mare"});
        CITIES_BY_COUNTY.put("TL", new String[]{"Tulcea", "Babadag", "Isaccea", "Măcin", "Sulina"});
        CITIES_BY_COUNTY.put("VL", new String[]{"Râmnicu Vâlcea", "Băbeni", "Bălcești", "Băile Govora", "Băile Olănești", "Berbești", "Brezoi", "Călimănești", "Drăgășani", "Horezu", "Ocnele Mari"});
        CITIES_BY_COUNTY.put("VS", new String[]{"Vaslui", "Bârlad", "Huși", "Murgeni", "Negrești"});
        CITIES_BY_COUNTY.put("VN", new String[]{"Focșani", "Adjud", "Mărășești", "Odobești", "Panciu"});
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String county = request.getParameter("judet");
        
        if (county == null || county.trim().isEmpty()) {
            out.print("[]");
            return;
        }
        
        // Create a JSON array with cities for the selected county
        JSONArray citiesArray = new JSONArray();
        
        // Get cities for the requested county
        String[] cities = CITIES_BY_COUNTY.get(county.toUpperCase());
        
        if (cities != null) {
            for (String city : cities) {
                JSONObject cityObj = new JSONObject();
                cityObj.put("nume", city);
                citiesArray.put(cityObj);
            }
        }
        
        // Return the JSON array
        out.print(citiesArray.toString());
    }
}