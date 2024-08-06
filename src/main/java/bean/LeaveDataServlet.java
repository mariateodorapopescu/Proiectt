package bean;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONObject;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

public class LeaveDataServlet extends HttpServlet {
	
	/**
	 * 
	 */
	private static final long serialVersionUID1 = 133523138237161389L;
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
		try {
	    	response.setContentType("application/json");
	    	response.setHeader("Access-Control-Allow-Origin", "*"); // For development only, specify domains in production
	    	response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
	    	response.setHeader("Access-Control-Allow-Headers", "Content-Type");

	        JSONArray events = new JSONArray();
	        try {
	            Class.forName("com.mysql.cj.jdbc.Driver"); // For MySQL Connector/J 8.0
	        } catch (ClassNotFoundException e) {
	            e.printStackTrace();
	            throw new ServletException("MySQL Driver not found", e);
	        }

	        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false&serverTimezone=UTC", "root", "student");
	             Statement statement = connection.createStatement();
	             ResultSet rs = statement.executeQuery("SELECT accent, nume, prenume, start_c, end_c FROM concedii join useri on concedii.id_ang = useri.id join teme on useri.id = teme.id_usr where concedii.status = 2")) {

	            while (rs.next()) {
	                JSONObject event = new JSONObject();
	                event.put("title", rs.getString("nume") + " " + rs.getString("prenume"));
	                event.put("start", rs.getDate("start_c").toString());
	                event.put("end", rs.getDate("end_c").toString());
	                event.put("color", rs.getString("accent")); // Example color
	                event.put("textColor", "white");
	                events.put(event);
	                System.out.println(events);
	    	        
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	            throw new ServletException("Eroare BD=(", e);
	        }
	        PrintWriter out = response.getWriter();
	        out.print(events.toString());
	    }
	    catch (Exception e) {
	        e.printStackTrace(); // Log server-side exceptions
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	        response.getWriter().write("Aparent are roare =( " + e.getMessage());
	    }
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    try {
	    	response.setContentType("application/json");
	    	response.setHeader("Access-Control-Allow-Origin", "*"); // For development only, specify domains in production
	    	response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
	    	response.setHeader("Access-Control-Allow-Headers", "Content-Type");

	        JSONArray events = new JSONArray();

	        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
	             Statement statement = connection.createStatement();
	             ResultSet rs = statement.executeQuery("SELECT accent, nume, prenume, start_c, end_c FROM concedii join useri on concedii.id_ang = useri.id join teme on useri.id = teme.id_usr where concedii.status = 2")) {

	            while (rs.next()) {
	                JSONObject event = new JSONObject();
	                event.put("title", rs.getString("nume") + " " + rs.getString("prenume"));
	                event.put("start", rs.getDate("start_c").toString());
	                event.put("end", rs.getDate("end_c").toString());
	                event.put("color", rs.getString("accent")); // Example color
	                event.put("textColor", "white");
	                events.put(event);
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	            throw new ServletException("Eroare BD=(", e);
	        }
	        System.out.println(events);
	        PrintWriter out = response.getWriter();
	        out.print(events.toString());
	        System.out.println(response);
	    }
	    catch (Exception e) {
	        e.printStackTrace(); // Log server-side exceptions
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	        response.getWriter().write("Internal Server Error: " + e.getMessage());
	    }
	}
}
