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
  ResultSet rs_product_check = null;
  PreparedStatement cell_amount = null;
  PreparedStatement customer_sale = null;
  PreparedStatement product_sale = null;
  int offsetProduct = 0;
  int offsetProductInc = 0;
  int offsetProductDec = 0;
  String rowOption = "";
  String orderOption = "";
  String categoryOption = "";

  try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql:cse135";
    String admin = "postgres";
    String password = "";
    conn = DriverManager.getConnection(url, admin, password);
  }
  catch (Exception e) {}
  Statement stmt = conn.createStatement();
  Statement stmt2 = conn.createStatement();
  Statement stmt3 = conn.createStatement();
  Statement stmt4 = conn.createStatement();
  
  ResultSet rs_categories = stmt3.executeQuery("select name from categories");

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    
    if (request.getParameter("addProduct")!= null){
      offsetProduct = Integer.parseInt(request.getParameter("addProduct"));
    }
    else{
      offsetProduct = 0;
    }
    offsetProductInc = offsetProduct + 10;
    offsetProductDec = offsetProduct - 10;

    if( request.getParameter("category_option") == null){
      categoryOption = (String)session.getAttribute("category_option");
    }
    else{
      categoryOption = request.getParameter("category_option");
      session.setAttribute("category_option", categoryOption);
    }

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

    if(rowOption.equals("states")){
      if(orderOption.equals("top_k") ){ //state top_K
        rs_stateOrCustomer = stmt.executeQuery(
          "select distinct state, round(cast(sum(o.quantity*o.price) as numeric),2) as amount "+
          "from users u, orders o where u.id = o.user_id group by state "+
          "union select distinct state, 0 from users "+
          "where state not in(select distinct state from users u, orders o where u.id=o.user_id) "+
          "order by amount desc limit 20;");

        if(categoryOption.equals("all")){
          rs_product = stmt2.executeQuery(
            "select id, Left(name,10) from products " +
            "order by name ASC " +
            "limit 10 offset " + offsetProduct + " ;" );
          rs_product_check = stmt4.executeQuery(
          "select * from products " +
          "limit 10 offset " + offsetProductInc + " ;" );
        }
        else{
          rs_product = stmt2.executeQuery(
            "select id, Left(name,10) from products p where " +
            "p.category_id=(select id from categories where name = "+ "\'" +categoryOption +   "\'"+ ") " +
            "order by name ASC " +
            "limit 10 offset " + offsetProduct + " ;" );

          rs_product_check = stmt4.executeQuery(
          "select * from products p where " +
          "p.category_id=(select id from categories where name = "+ "\'" +categoryOption +   "\'"+ ") " +
          "limit 10 offset " + offsetProductInc + " ;" );
        }

        product_sale = conn.prepareStatement(
          "select round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
          "from products p, orders o "+
          "where p.id = ? and o.product_id = p.id and o.is_cart = false "+
          "group by p.id; ");
        cell_amount = conn.prepareStatement(
          "select round(cast((o.price*o.quantity) as numeric),2) as amount "+
          "from orders o "+
          "where o.product_id = ? and o.user_id = ? and o.is_cart = false ");
      }
      else{ //states alphabetical
        
      }
    }
    else{ 
      if(orderOption.equals("top_k") ){ //customer top_K
        
      }
      else{ //customer, alphabetical
        rs_stateOrCustomer = stmt.executeQuery(
          "select id, name from users order by name asc limit 20");
        customer_sale = conn.prepareStatement(
          "select round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
          "from orders o, users u "+ 
          "where u.id = ? and u.id = o.user_id and o.is_cart = false " +
          "group by u.id; ");

        if(categoryOption.equals("all")){
          rs_product = stmt2.executeQuery(
            "select id, Left(name,10) from products " +
            "order by name ASC " +
            "limit 10 offset " + offsetProduct + " ;" );
          rs_product_check = stmt4.executeQuery(
          "select * from products " +
          "limit 10 offset " + offsetProductInc + " ;" );
        }
        else{
          rs_product = stmt2.executeQuery(
            "select id, Left(name,10) from products p where " +
            "p.category_id=(select id from categories where name = "+ "\'" +categoryOption +   "\'"+ ") " +
            "order by name ASC " +
            "limit 10 offset " + offsetProduct + " ;" );

          rs_product_check = stmt4.executeQuery(
          "select * from products p where " +
          "p.category_id=(select id from categories where name = "+ "\'" +categoryOption +   "\'"+ ") " +
          "limit 10 offset " + offsetProductInc + " ;" );
        }

       

        product_sale = conn.prepareStatement(
          "select round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
          "from products p, orders o "+
          "where p.id = ? and o.product_id = p.id and o.is_cart = false "+
          "group by p.id; ");
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
      <%if(request.getParameter("row_option")!=null && 
            request.getParameter("row_option").equals("states")) {%>
          <option value = "customers">Customers</option>
          <option selected value = "states">States</option>
       <%} 
       else{%>
          <option selected value = "customers">Customers</option>
          <option value = "states">States</option>
       <%}%>
    </select>

    <select name = "order_option" >
       <% if(request.getParameter("order_option")!=null && 
            request.getParameter("order_option").equals("top_k")) {%>
          <option value = "alphabetical">Alphabetical</option>
          <option selected value = "top_k">Top-K</option>      
       <%} 
       else{%>
          <option selected value = "alphabetical">Alphabetical</option>
          <option value = "top_k">Top-K</option>
       <%}%>
    </select>
    <select name = "category_option" >
      <option selected value = "all">All</option>
      <%while(rs_categories.next()){
          String category = rs_categories.getString("name");
          if(categoryOption != "" && 
            categoryOption.equals(category)) {%>
            <option selected value="<%=category%>">
              <%=category%>
            </option>
          <%}
          else{%>
            <option value="<%=category%>">
              <%=category%>
            </option>
          <%}
        }%>
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
      String customerSpending = "0"; 

      ResultSet salesAmount = null;

      while (rs_stateOrCustomer.next()) { 
        if (rowOption.equals("customers")){%>
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
              <td><%= "$ 0 "%></td>
              <%
            }
          }
          %></tr><%
        }
        else{%> 
          <tr>
          <td><b><%=rs_stateOrCustomer.getString("state")+ " ("+
            rs_stateOrCustomer.getString("amount")+")"%></b></td>
          </tr>
        <%}
      }
  } %>
</table>

<%if ("POST".equalsIgnoreCase(request.getMethod())) { %>
<div> 
  <%if(offsetProductDec >= 0){%>
  <form action= "orders.jsp" method="POST"> 
    <input type="hidden" type="number" name="addProduct" value="<%=offsetProductDec%>"><%=offsetProductDec%>
    <input type="submit" value = "Previous 10 Product"/>
  </form>
  <%}%>

  <%if( rs_product_check.next()){ %>
    <form action= "orders.jsp" method="POST"> 
      <input type="hidden" type="number" name="addProduct" value="<%=offsetProductInc%>"><%=offsetProductInc%>
      <input type="submit" value = "Next 10 Product"/>
    </form> 
  <%}%>
</div>

<%}%>

</body>
</html>