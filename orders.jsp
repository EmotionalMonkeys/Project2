<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>
<% 
  Connection conn = null;
  try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql:cse135";
    String admin = "postgres";
    String password = "";
    conn = DriverManager.getConnection(url, admin, password);
  }
  catch (Exception e) {}
  ResultSet rs = null;

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String rowOption = request.getParameter("row_option");
    String orderOption = request.getParameter("order_option");
    Statement stmt = conn.createStatement();

    if(rowOption.equals("states")){
      if(orderOption.equals("top_k") ){
        rs = stmt.executeQuery("SELECT state FROM users order by state asc");
      }
      else{

      }

    }
    else{
      if(orderOption.equals("top_k") ){
        rs = stmt.executeQuery("");
      }
      else{

      }
    }
  }
%>

<body>
<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>

<div>
  <form action="orders.jsp" method="POST">
    <select name = "row_option">
      <option value = "customers" name = "customers">Customers</option>
      <option value = "states">States</option>
    </select>
    <select name = "order_option" >
      <option value = "alphabetical">Alphabetical</option>
      <option value = "top_k">Top-K</option>
    </select>
    <select name = "filter_option" >
      <option value = "all">All</option>
      <option value = "top_k">Top-K</option>
    </select>
    <input type="submit" value = "Run Query"/>
  </form>
</div>

<table class="table table-striped">
  <th><bold>State</bold></th>
  <% if(rs != null) { 
        while (rs.next()) { %>
  <tr>
    <td><%=rs.getString("state")%></td>
  </tr>
  <% } }
   else
     out.println("<script>alert('Something went wrong');</script>");
%>
</table>




</body>
</html>