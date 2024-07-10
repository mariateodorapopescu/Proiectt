<%@ page isErrorPage="true" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<html>
<body>
<p>Oh, no... =(</p>
<p><%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "An unknown error occurred." %></p>

</body>
</html>
