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
  Statement stmt = conn.createStatement();
  ResultSet rs = stmt.executeQuery(
    "with temp as(select u.p1, u.p2, (sum(u.amount) /(u2.s1 * u3.s1 )) as result from  "+
    "  (select o1.product_id as p1, o2.product_id as p2, o1.price*o2.price as amount "+
    "  from orders o1, orders o2 "+
    "  where o1.product_id < o2.product_id and o1.user_id = o2.user_id ) u , "+
    "  (select o.product_id as p, sum(o.price) as s1 "+
    "  from orders o group by o.product_id) u2,  "+
    "  (select o.product_id as p, sum(o.price) as s1 "+
    "  from orders o group by o.product_id) u3 "+
    "where u.p1 = u2.p and u.p2 = u3.p  "+
    "group by u.p1,u.p2, u2.s1, u3.s1 "+
    "order by result DESC limit 100)  "+
    "select Left(pro_1.name,10) as p1, Left(pro_2.name,10) as p2 "+
    "from temp, products pro_1, products pro_2 "+
    "where temp.p1 = pro_1.id and temp.p2 = pro_2.id; "


  );
 
%>

<body>
<div class="collapse navbar-collapse">
  <ul class="nav navbar-nav">
    <li><a href="index.jsp">Home</a></li>
    <li><a href="categories.jsp">Categories</a></li>
    <li><a href="products.jsp">Products</a></li>
    <li><a href="orders.jsp">Orders</a></li>
    <li><a href="similar_products.jsp">Similar Products</a></li>
    <li><a href="login.jsp">Logout</a></li>
  </ul>
</div>

<table class="table table-striped">
  <th> Similar Products </th>
 <%while(rs.next()){%>
    <tr><td><%= rs.getString("p1")%></td>   
        <td><%= rs.getString("p2")%></td>
    </tr>

<%}%>
</table>

</body>
</html>