package Servlet;

import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Procesor pentru politicile companiei și regulament
 * Gestionează rezumatul regulamentului și verificarea permisiunilor
 */
public class CompanyPolicyProcessor {
    
    // Regulamentul companiei (text prefacut standard)
    private static final String COMPANY_REGULATION = 
        		"REGULAMENTUL INTERN AL COMPANIEI " + 
        
        "CAPITOLUL I - DISPOZIȚII GENERALE" +
        "Prezentul regulament se aplică tuturor angajaților companiei și reglementează drepturile și obligațiile acestora în cadrul relației de muncă." +
        
        "CAPITOLUL II - PROGRAMUL DE LUCRU" +
        "Programul normal de lucru este de 8 ore pe zi, între orele 09:00-17:00, cu pauza de masă de 1 oră între 12:00-13:00." +
        "Angajații pot beneficia de program flexibil între orele 08:00-18:00, cu acordul managerului direct." +
        "Munca de acasă (remote work) este permisă maximum 3 zile pe săptămână, cu aprobarea prealabilă." +
        "Orele suplimentare se compensează cu timp liber sau se plătesc cu spor de 75%." +
        
        "CAPITOLUL III - CONCEDII ȘI ABSENȚE" +
        "Concediul de odihnă anual este de 21 zile lucrătoare pentru angajații cu peste 5 ani vechime și 25 zile pentru cei cu peste 10 ani." +
        "Concediul medical se acordă pe baza certificatului medical, fără limită de timp." +
        "Concediul fără plată poate fi acordat maximum 30 zile pe an, cu acordul managerului." +
        "Absențele nemotivate se sancționează conform legislației în vigoare." +
        
        "CAPITOLUL IV - DREPTURI ȘI OBLIGAȚII" +
        "Angajații au dreptul la formare profesională continuă, promovare pe bază de merit și mediu de lucru sigur." +
        "Angajații au obligația să respecte confidențialitatea datelor companiei și să nu divulge informații comerciale." +
        "Este interzisă folosirea echipamentelor companiei în scopuri personale în timpul programului de lucru." +
        "Consumul de alcool și substanțe interzise pe proprietatea companiei este strict interzis." +
        
        "CAPITOLUL V - EVALUAREA PERFORMANȚEI" +
        "Evaluarea performanței se face anual și poate duce la majorări salariale sau promovări." +
        "Angajații cu performanțe scăzute vor fi incluși în programe de îmbunătățire." +
        "Performanțele excepționale sunt recompensate cu bonusuri și recunoaștere publică." +
        
        "CAPITOLUL VI - DISCIPLINA MUNCII" +
        "Întârzierea sistematică (peste 3 întârzieri pe lună) se sancționează cu avertisment scris." +
        "Lipsele nemotivate se sancționează cu rețineri salariale sau avertisment disciplinar." +
        "Nerespectarea confidențialității poate duce la desfacerea contractului de muncă." +
        "Violența fizică sau verbală este motiv de concediere imediată." +
        
        "CAPITOLUL VII - BENEFICII ȘI FACILITĂȚI" +
        "Angajații beneficiază de asigurare medicală privată după 6 luni de vechime." +
        "Tichetele de masă se acordă pentru zilele lucrate efectiv." +
        "Programele de formare sunt gratuite și încurajate." +
        "Facilități pentru părinți: program redus și zile libere suplimentare pentru îngrijirea copiilor." +
        
        "CAPITOLUL VIII - TEHNOLOGIA ȘI SECURITATEA" +
        "Accesul la internet este monitorizat și trebuie folosit responsabil." +
        "Parolele trebuie schimbate la fiecare 3 luni și să conțină caractere speciale." +
        "Descărcarea de software neautorizat este interzisă." +
        "Datele companiei trebuie salvate doar pe servere autorizate." +
        
        "CAPITOLUL IX - COMUNICAREA INTERNĂ" +
        "Comunicarea oficială se face prin email corporativ sau platformele aprobate." +
        "Reclamațiile se depun la departamentul HR sau prin sistemul de feedback anonim." +
        "Reuniunile de echipă sunt obligatorii și se țin săptămânal." +
        
        "CAPITOLUL X - DISPOZIȚII FINALE" +
        "Prezentul regulament intră în vigoare de la data semnării și poate fi modificat cu acordul părților." +
        "Nerespectarea regulamentului atrage răspunderea disciplinară conform legislației muncii.";
    
    // Cuvinte cheie pentru detectarea tipului de întrebare
    private static final Map<String, List<String>> POLICY_KEYWORDS = new HashMap<>();
    static {
        // Acțiuni permise (răspuns pozitiv)
        POLICY_KEYWORDS.put("ALLOWED", Arrays.asList(
            "lucru acasa", "remote", "program flexibil", "formare", "cursuri", "concediu medical",
            "concediu fara plata", "pauza masa", "tichet masa", "asigurare medicala", "bonus",
            "evaluare", "promovare", "reclamatii", "feedback", "ore suplimentare", "compensare",
            "schimbare parola", "reuniuni echipa", "zile libere parinti"
        ));
        
        // Acțiuni interzise (răspuns negativ)
        POLICY_KEYWORDS.put("FORBIDDEN", Arrays.asList(
            "alcool", "substante", "violenta", "echipamente personale", "software neautorizat",
            "divulgare informatii", "confidentialitate", "absente nemotivate", "intarzieri",
            "internet personal", "date externe", "comunicare neoficiala"
        ));
        
        // Acțiuni condiționate (răspuns cu condiții)
        POLICY_KEYWORDS.put("CONDITIONAL", Arrays.asList(
            "munca acasa", "program flexibil", "ore suplimentare", "concediu", "formare externa",
            "acces internet", "utilizare echipamente", "comunicare"
        ));
    }
    
    // Pattern pentru detectarea întrebărilor de tip "pot să"/"am voie"
    private static final Pattern PERMISSION_PATTERN = Pattern.compile(
        "\\b(pot sa|pot să|am voie|este permis|se poate|este legal|am dreptul)\\b",
        Pattern.CASE_INSENSITIVE
    );
    
    /**
     * Generează un rezumat al regulamentului companiei
     */
    public static String generateRegulationSummary() {
        StringBuilder summary = new StringBuilder();
        
        summary.append("**📋 REZUMAT REGULAMENT COMPANIE**\n\n");
        
        summary.append("**🕒 PROGRAM LUCRU:**\n");
        summary.append("• Program standard: 09:00-17:00 cu pauză 12:00-13:00\n");
        summary.append("• Program flexibil: 08:00-18:00 (cu aprobare manager)\n");
        summary.append("• Remote work: max 3 zile/săptămână\n");
        summary.append("• Ore suplimentare: compensare timp liber sau +75% plată\n\n");
        
        summary.append("**🏖️ CONCEDII:**\n");
        summary.append("• Concediu anual: 21 zile (5+ ani vechime), 25 zile (10+ ani)\n");
        summary.append("• Concediu medical: nelimitat cu certificat\n");
        summary.append("• Concediu fără plată: max 30 zile/an cu aprobare\n\n");
        
        summary.append("**💰 BENEFICII:**\n");
        summary.append("• Asigurare medicală privată (după 6 luni)\n");
        summary.append("• Tichete de masă pentru zilele lucrate\n");
        summary.append("• Programe formare gratuite\n");
        summary.append("• Facilități pentru părinți\n\n");
        
        summary.append("**⚠️ OBLIGAȚII PRINCIPALE:**\n");
        summary.append("• Respectarea confidențialității datelor\n");
        summary.append("• Folosirea responsabilă a echipamentelor\n");
        summary.append("• Participarea la reuniunile de echipă\n");
        summary.append("• Schimbarea parolelor la 3 luni\n\n");
        
        summary.append("**🚫 INTERZIS:**\n");
        summary.append("• Alcool și substanțe pe proprietatea companiei\n");
        summary.append("• Divulgarea informațiilor confidențiale\n");
        summary.append("• Software neautorizat\n");
        summary.append("• Violența fizică sau verbală\n\n");
        
        summary.append("**📊 EVALUARE & SANCȚIUNI:**\n");
        summary.append("• Evaluare anuală pentru promovări/majorări\n");
        summary.append("• Întârzieri sistematice: avertisment scris\n");
        summary.append("• Absențe nemotivate: rețineri salariale\n");
        summary.append("• Încălcare confidențialitate: desfacere contract\n\n");
        
        summary.append("*Pentru detalii complete, consultați regulamentul intern complet.*");
        
        return summary.toString();
    }
    
    /**
     * Verifică dacă o acțiune este permisă conform politicilor companiei
     */
    public static PolicyResponse checkPolicyPermission(String query) {
        String normalizedQuery = query.toLowerCase()
            .replace("ă", "a")
            .replace("â", "a")
            .replace("î", "i")
            .replace("ș", "s")
            .replace("ț", "t");
        
        // Verifică dacă este o întrebare de tip permisiune
        if (!PERMISSION_PATTERN.matcher(normalizedQuery).find()) {
            return new PolicyResponse(
                PolicyResult.UNCLEAR,
                "Nu am detectat o întrebare despre permisiuni. Încercați să reformulați cu 'pot să...' sau 'am voie să...'?"
            );
        }
        
        // Analizează cuvintele cheie
        PolicyResult result = analyzePolicyKeywords(normalizedQuery);
        String explanation = generatePolicyExplanation(normalizedQuery, result);
        
        return new PolicyResponse(result, explanation);
    }
    
    /**
     * Analizează cuvintele cheie pentru a determina răspunsul
     */
    private static PolicyResult analyzePolicyKeywords(String query) {
        int allowedScore = 0;
        int forbiddenScore = 0;
        int conditionalScore = 0;
        
        // Calculează scorurile pentru fiecare categorie
        for (String keyword : POLICY_KEYWORDS.get("ALLOWED")) {
            if (query.contains(keyword)) {
                allowedScore += keyword.split(" ").length; // Cuvinte compuse = scor mai mare
            }
        }
        
        for (String keyword : POLICY_KEYWORDS.get("FORBIDDEN")) {
            if (query.contains(keyword)) {
                forbiddenScore += keyword.split(" ").length;
            }
        }
        
        for (String keyword : POLICY_KEYWORDS.get("CONDITIONAL")) {
            if (query.contains(keyword)) {
                conditionalScore += keyword.split(" ").length;
            }
        }
        
        // Determină rezultatul pe baza scorurilor
        if (forbiddenScore > 0) {
            return PolicyResult.NO;
        } else if (allowedScore > conditionalScore) {
            return PolicyResult.YES;
        } else if (conditionalScore > 0) {
            return PolicyResult.CONDITIONAL;
        } else {
            return PolicyResult.UNCLEAR;
        }
    }
    
    /**
     * Generează explicația pentru răspunsul dat
     */
    private static String generatePolicyExplanation(String query, PolicyResult result) {
        StringBuilder explanation = new StringBuilder();
        
        switch (result) {
            case YES:
                explanation.append("**✅ DA** - Această acțiune este permisă conform regulamentului companiei.\n\n");
                
                if (query.contains("remote") || query.contains("acasa")) {
                    explanation.append("🏠 **Munca de acasă**: Permisă maximum 3 zile pe săptămână cu aprobarea managerului direct.");
                } else if (query.contains("flexibil")) {
                    explanation.append("⏰ **Program flexibil**: Permis între orele 08:00-18:00 cu acordul managerului.");
                } else if (query.contains("formare") || query.contains("cursuri")) {
                    explanation.append("📚 **Formare profesională**: Programele de formare sunt gratuite și încurajate.");
                } else if (query.contains("concediu")) {
                    explanation.append("🏖️ **Concediu**: Concediul de odihnă și medical sunt drepturi garantate.");
                } else if (query.contains("ore suplimentare")) {
                    explanation.append("⏳ **Ore suplimentare**: Se compensează cu timp liber sau se plătesc cu spor de 75%.");
                } else {
                    explanation.append("Această acțiune este în conformitate cu politicile companiei.");
                }
                break;
                
            case NO:
                explanation.append("**❌ NU** - Această acțiune este interzisă conform regulamentului companiei.\n\n");
                
                if (query.contains("alcool") || query.contains("substante")) {
                    explanation.append("🚫 **Substanțe interzise**: Consumul de alcool și substanțe interzise pe proprietatea companiei este strict interzis.");
                } else if (query.contains("confidential") || query.contains("divulg")) {
                    explanation.append("🔒 **Confidențialitate**: Divulgarea informațiilor comerciale confidențiale este interzisă și poate duce la desfacerea contractului.");
                } else if (query.contains("software") || query.contains("download")) {
                    explanation.append("💻 **Software neautorizat**: Descărcarea și instalarea de software neautorizat este interzisă.");
                } else if (query.contains("violenta")) {
                    explanation.append("⚠️ **Violența**: Violența fizică sau verbală este motiv de concediere imediată.");
                } else {
                    explanation.append("Această acțiune încalcă regulamentul intern al companiei.");
                }
                break;
                
            case CONDITIONAL:
                explanation.append("**⚠️ CONDIȚIONAT** - Această acțiune este permisă doar în anumite condiții.\n\n");
                explanation.append("Pentru a obține o aprobare, contactați managerul direct sau departamentul HR pentru detalii specifice.");
                break;
                
            case UNCLEAR:
                explanation.append("**❓ NU SUNT SIGUR** - Nu am găsit informații specifice în regulament despre această situație.\n\n");
                explanation.append("📞 **Recomandare**: Contactați departamentul HR la extensia 100 sau email hr@companie.ro pentru clarificări.\n");
                explanation.append("💡 **Alternativ**: Verificați regulamentul intern complet disponibil în sistemul intern al companiei.");
                break;
        }
        
        return explanation.toString();
    }
    
    /**
     * Enum pentru rezultatele verificării politicilor
     */
    public enum PolicyResult {
        YES,         // Permis
        NO,          // Interzis
        CONDITIONAL, // Condiționat
        UNCLEAR      // Neclar
    }
    
    /**
     * Clasa pentru răspunsul verificării politicilor
     */
    public static class PolicyResponse {
        private PolicyResult result;
        private String explanation;
        
        public PolicyResponse(PolicyResult result, String explanation) {
            this.result = result;
            this.explanation = explanation;
        }
        
        public PolicyResult getResult() { return result; }
        public String getExplanation() { return explanation; }
        
        /**
         * Returnează răspunsul formatat pentru chat
         */
        public String getFormattedResponse() {
            return explanation;
        }
        
        /**
         * Returnează răspunsul simplu (DA/NU/CONDIȚIONAT/NECLAR)
         */
        public String getSimpleAnswer() {
            switch (result) {
                case YES: return "DA";
                case NO: return "NU";
                case CONDITIONAL: return "CONDIȚIONAT";
                case UNCLEAR: return "NECLAR";
                default: return "NECUNOSCUT";
            }
        }
    }
}