<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*, java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>
<% 
  Connection conn = null;
  ResultSet rs_stateOrCustomer = null;
  ResultSet rs_product = null;
  PreparedStatement cell_amount = null;
  PreparedStatement customer_sale = null;
  PreparedStatement product_sale = null;

  try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql:cse135";
    String admin = "postgres";
    String password = "";
    conn = DriverManager.getConnection(url, admin, password);
  }
  catch (Exception e) {}

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String rowOption = request.getParameter("row_option");
    String orderOption = request.getParameter("order_option");
    Statement stmt = conn.createStatement();
    Statement stmt2 = conn.createStatement();

    if(rowOption.equals("states")){
      if(orderOption.equals("top_k") ){
        //rs = stmt.executeQuery("SELECT state FROM users order by state asc");
      }
      else{

      }

    }
    else{
      if(orderOption.equals("top_k") ){
        //rs = stmt.executeQuery("");
      }
      else{
        rs_stateOrCustomer = stmt.executeQuery(
          "select id, name from users order by name asc limit 20");
        customer_sale = conn.prepareStatement(
          "select round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
          "from orders o, users u "+ 
          "where u.id = ? and u.id = o.user_id and o.is_cart = false " +
          "group by u.id; ");
          /*"with temp as (SELECT u.name, u.id " +
          "from users u " +
          "order by u.name ASC " +
          "LIMIT 20)" +
          "SELECT p.id, p.name, round( cast(SUM(o.quantity * o.price) as numeric),2) as amount " +
          "FROM orders o, temp p " +
          "where o.user_id = p.id and " +
          "o.is_cart = false " +
          "group by p.id, p.name order by p.name ASC; ");*/
        rs_product = stmt2.executeQuery(
          "select id, Left(name,10) from products " +
          "order by name ASC " +
          "limit 10;" );
        product_sale = conn.prepareStatement(
          "select round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
          "from products p, orders o "+
          "where p.id = ? and o.product_id = p.id and o.is_cart = false "+
          "group by p.id; ");

          /*"select p.id,Left(p.name,10), SUM(o.quantity * o.price) as amount " +
          "from products p, orders o " +
          "where o.product_id = p.id and o.is_cart = false " +
          "group by p.name,p.id " +
          "order by p.name ASC " +
          "limit 10 offset 0;");*/
        cell_amount = conn.prepareStatement(
          "select round(cast((o.price*o.quantity) as numeric),2) as amount "+
          "from orders o "+
          "where o.product_id = ? and o.user_id = ? and o.is_cart = false ");
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
  <%if(rs_stateOrCustomer!=null && rs_product!=null && cell_amount!=null) { 
      %>

      <th></th>
      <%ArrayList productList = new ArrayList(); 
        
         
        ResultSet productAmount = null;
        String productSpending = "0";

        
        while(rs_product.next()){
          product_sale.setInt(1, Integer.parseInt(rs_product.getString("id")));
          productAmount = product_sale.executeQuery();
          if(productAmount!= null && productAmount.next()){
            productSpending = productAmount.getString("amount");
          }

          %>
          <th><%=rs_product.getString("left") + " (" + productSpending + ")"%></th>
          <%productList.add(rs_product.getString("id"));   
        }

       
        ResultSet customerAmount = null;
        String customerSpending = "0"; 

        ResultSet salesAmount = null;

        while (rs_stateOrCustomer.next()) { 
          if (request.getParameter("row_option").equals("customers")){%>
          <tr>

            <%  customer_sale.setInt(1, Integer.parseInt(rs_stateOrCustomer.getString("id")));
                customerAmount = customer_sale.executeQuery();
                if(customerAmount!= null && customerAmount.next()){
                  customerSpending = customerAmount.getString("amount");
                }
               %>
            <td><b><%=rs_stateOrCustomer.getString("name")+ " ("+customerSpending+")"%></b></td>

            <%for(int counter = 0; counter < productList.size(); counter++){
                cell_amount.setInt(1, Integer.valueOf((String)productList.get(counter)));
                cell_amount.setInt(2, Integer.parseInt(rs_stateOrCustomer.getString("id")));
                salesAmount = cell_amount.executeQuery();

                if (salesAmount!= null && salesAmount.next()){ %>
                  <td><%= "$ " + salesAmount.getString("amount") %></td>
                  <%
                }
                else {%>
                  <td><%= "$0 "%></td><%
                }
              }
 
          }
        }
    }
    
  %>
</table>




</body>
</html>