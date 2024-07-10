package bean;

import javax.sql.DataSource;
import java.sql.*;

public class UserData {
    private DataSource dataSource;

    public UserData(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public String getPrenumeByUsername(String username) throws SQLException {
        String prenume = null;
        String sql = "SELECT prenume FROM useri WHERE username = ?";
               try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    prenume = rs.getString("prenume");
                }
            }
        }
        return prenume;
    }
}
