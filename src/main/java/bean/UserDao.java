package bean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

public class UserDao {

	 private DataSource dataSource;

	    public UserDao(DataSource dataSource) {
	        this.dataSource = dataSource;
	    }

	    public List<UserView> list() throws SQLException {
	        List<UserView> products = new ArrayList<UserView>();

	        try (
	            Connection connection = dataSource.getConnection();
	            PreparedStatement statement = connection.prepareStatement("select username, denumire as tip, nume_dep as departament from useri natural join departament natural join tipuri");
	            ResultSet resultSet = statement.executeQuery();
	        ) {
	            while (resultSet.next()) {
	                UserView product = new UserView();
	                product.setUsername(resultSet.getString("username"));
	                product.setDepartament(resultSet.getString("departament"));
	                product.setTip(resultSet.getString("tip"));
	                products.add(product);
	            }
	        }
	        return products;
	    }
	    public List<String> getTipuri() throws SQLException {
	        List<String> tipuri = new ArrayList<>();
	        try (Connection connection = dataSource.getConnection();
	             PreparedStatement pstmt = connection.prepareStatement("SELECT denumire FROM tipuri")) {
	            ResultSet rs = pstmt.executeQuery();
	            while (rs.next()) {
	                tipuri.add(rs.getString("denumire"));
	            }
	        }
	        return tipuri;
	    }

	    public List<String> getDepartamente() throws SQLException {
	        List<String> departamente = new ArrayList<>();
	        try (Connection connection = dataSource.getConnection();
	             PreparedStatement pstmt = connection.prepareStatement("SELECT nume_dep FROM departament")) {
	            ResultSet rs = pstmt.executeQuery();
	            while (rs.next()) {
	                departamente.add(rs.getString("nume_dep"));
	            }
	        }
	        return departamente;
	    }

}
