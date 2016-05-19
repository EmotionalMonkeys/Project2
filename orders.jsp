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
  PreparedStatement state_sale = null;
  PreparedStatement product_sale = null;
  int offsetProduct = 0;
  int offsetProductInc = 0;
  int offsetProductDec = 0;
  String rowOption = "";
  String orderOption = "";

  try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql:cse135";
    String admin = "postgres";
    String password = "";
    conn = DriverManager.getConnection(url, admin, password);
  }
  catch (Exception e) {}

  if ("POST".equalsIgnoreCase(request.getMethod())) {


    if (request.getParameter("addProduct")!= null){
      offsetProduct = Integer.parseInt(request.getParameter("addProduct"));
    }
    else{
      offsetProduct = 0;
    }
    offsetProductInc = offsetProduct + 10;


    if( request.getParameter("row_option") == null){
      rowOption = (String)session.getAttribute("row_option");
    }
    else{
      rowOption = request.getParameter("row_option");
      session.setAttribute("row_option", rowOption);
    }

    if( request.getParameter("order_option") == null){
      orderOption = (String)session.getAttribute("order_option");
    }
    else{ 
      orderOption = request.getParameter("order_option");
      session.setAttribute("order_option", orderOption);
    }


    Statement stmt = conn.createStatement();
    Statement stmt2 = conn.createStatement();

    if(rowOption.equals("states")){
      if(orderOption.equals("top_k") ){
        //rs = stmt.executeQuery("SELECT state FROM users order by state asc");
        rs_stateOrCustomer = stmt.executeQuery(
          "select id, state from users order by state desc limit 20");
        state_sale = conn.prepareStatement(
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
      else{
        rs_stateOrCustomer = stmt.executeQuery(
          "select id, state from users order by state asc limit 20");
        state_sale = conn.prepareStatement(
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
          "limit 10 offset " + offsetProduct + " ;" );
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
    <select name = "row_option" >
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

<table class="table table-striped"><%
  if(rs_stateOrCustomer!=null && rs_product!=null && cell_amount!=null) { 
    %>
    <th></th>
    <%
      ArrayList productList = new ArrayList(); 
         
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
      ResultSet stateAmount = null;
      String customerSpending = "0"; 
      String stateSpending = "0"; 

      ResultSet salesAmount = null;

      while (rs_stateOrCustomer.next()) { 
        if (rowOption.equals("customers")){%>
        <tr>

        <%  customer_sale.setInt(1, Integer.parseInt(rs_stateOrCustomer.getString("id")));
            customerAmount = customer_sale.executeQuery();
            if(customerAmount!= null && customerAmount.next()){
              customerSpending = customerAmount.getString("amount");
            }
            else
                  customerSpending = "0";
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
              <td><%= "$ 0 "%></td>
              <%
            }
          }

        }
        else if (request.getParameter("row_option").equals("states")) {%>
        <tr>

            <%  state_sale.setInt(1, Integer.parseInt(rs_stateOrCustomer.getString("id")));
                stateAmount = state_sale.executeQuery();
                if(stateAmount!= null && stateAmount.next()){
                  stateSpending = stateAmount.getString("amount");
                }
                else
                  stateSpending = "0";
            %>
            <td><b><%=rs_stateOrCustomer.getString("state")+ " ("+stateSpending+")"%></b></td>

            <%for(int counter = 0; counter < productList.size(); counter++){
                cell_amount.setInt(1, Integer.valueOf((String)productList.get(counter)));
                cell_amount.setInt(2, Integer.parseInt(rs_stateOrCustomer.getString("id")));
                salesAmount = cell_amount.executeQuery();

                if (salesAmount!= null && salesAmount.next()){ %>
                  <td><%= "$ " + salesAmount.getString("amount") %></td>
                  <%
                }
                else {%>
                  <td><%= "$ 0 "%></td><%
                }
              }

          }
      }
    } %>
</table>

<%if ("POST".equalsIgnoreCase(request.getMethod())) { %>
<div> 
  <form action= "orders.jsp" method="POST"> 
    <input type="hidden" type="number" name="addProduct" value="<%=offsetProductDec%>">
    <input type="submit" value = "Previous 10 Product"/>
  </form>

  <form action= "orders.jsp" method="POST"> 
    <input type="hidden" type="number" name="addProduct" value="<%=offsetProductInc%>">
    <input type="submit" value = "Next 10 Product"/>
  </form> 
</div>

<%}%>

</body>
</html>