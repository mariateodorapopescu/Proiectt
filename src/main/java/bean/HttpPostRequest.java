package bean;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class HttpPostRequest {
    public void sendPost(String username) throws Exception {
        String urlParameters = "username=" + username;
        byte[] postData = urlParameters.getBytes(StandardCharsets.UTF_8);

        URL myurl = new URL("http://example.com/dashboard.jsp");
        HttpURLConnection con = (HttpURLConnection) myurl.openConnection();

        con.setDoOutput(true);
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        con.setRequestProperty("Content-Length", String.valueOf(postData.length));

     }
}
