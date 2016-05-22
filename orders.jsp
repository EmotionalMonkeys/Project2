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
  ResultSet rs_stateOrCustomer_check = null;
  ResultSet rs_product = null;
  ResultSet rs_product_check = null;
  PreparedStatement cell_amount = null;

  String offsetp = "";
  String offsetcs = "";

  int offsetProduct = 0;
  int offsetProductInc = 0;
  int offsetCS = 0;
  int offsetCSInc = 0;
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
  Statement stmt5 = conn.createStatement();
  
  ResultSet rs_categories = stmt3.executeQuery("select name from categories");

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    if( request.getParameter("category_option") == null){
      categoryOption = (String)session.getAttribute("category_option");
    }
    else{
      categoryOption = request.getParameter("category_option");
      session.setAttribute("category_option", categoryOption);
      offsetp = offsetcs = "0";
      session.setAttribute("offsetp", offsetp);
      session.setAttribute("offsetcs", offsetcs);


     
    }

    if( request.getParameter("row_option") == null){
      rowOption = (String)session.getAttribute("row_option");
    }
    else{
      rowOption = request.getParameter("row_option");
      session.setAttribute("row_option", rowOption);
      offsetp = offsetcs = "0";
      session.setAttribute("offsetp", offsetp);
      session.setAttribute("offsetcs", offsetcs);

      
    }

    if( request.getParameter("order_option") == null){
      orderOption = (String)session.getAttribute("order_option");
    }
    else{ 
      orderOption = request.getParameter("order_option");
      session.setAttribute("order_option", orderOption);
      offsetp = offsetcs = "0";
      session.setAttribute("offsetp", offsetp);
      session.setAttribute("offsetcs", offsetcs);


    }


    if (request.getParameter("addProduct")== null && session.getAttribute("offsetp") != null){
      offsetp = (String)session.getAttribute("offsetp");
      offsetProduct = Integer.parseInt(offsetp);
    }
    else{
      offsetProduct = 
        ((session.getAttribute("offsetp") == null)? 0: Integer.parseInt(request.getParameter("addProduct")));
      offsetp = new Integer(offsetProduct).toString();
      session.setAttribute("offsetp", offsetp);
    }
     offsetProductInc = offsetProduct + 10;



    if (request.getParameter("addCS")== null && session.getAttribute("offsetcs") != null){
      offsetcs = (String)session.getAttribute("offsetcs");
      offsetCS = Integer.parseInt(offsetcs);
    }
    else{
      offsetCS = 
        ((session.getAttribute("offsetcs") == null)? 0: Integer.parseInt(request.getParameter("addCS")));
      offsetcs = new Integer(offsetCS).toString();
      session.setAttribute("offsetcs", offsetcs);
    }
    offsetCSInc = offsetCS + 20;

// ============================  Product Top-k ============================ //
    if(orderOption.equals("top_k") ){ 
      if(categoryOption.equals("all")){
        rs_product = stmt2.executeQuery(
          "SELECT p.id,Left(p.name,10),round(cast(sum( o.price * o.quantity) as numeric),2) "+
          "as amount "+  
          "FROM products p left outer join orders o on "+
          "p.id = o.product_id "+
          "GROUP BY p.name, p.id "+
          "ORDER BY amount DESC NULLS LAST "+
          "LIMIT 10 offset " + offsetProduct + " ;");

        rs_product_check = stmt4.executeQuery(//
          "SELECT p.id "+
          "as amount "+  
          "FROM products p left outer join orders o on "+
          "p.id = o.product_id "+
          "GROUP BY p.name, p.id "+
          "ORDER BY amount DESC NULLS LAST "+
          "LIMIT 10 offset " + offsetProductInc + " ;");
      }
      else{ //selected category
        rs_product = stmt2.executeQuery(
          "SELECT p.id,Left(p.name,10),round(cast(sum(o.price * o.quantity) as numeric),2) "+
          "as amount "+
          "FROM products p left outer join orders o on p.id = o.product_id "+ 
          "where p.category_id = "+
          "(select id from categories where name = "+"\'"+categoryOption+"\'"+") "+
          "GROUP BY p.name, p.id "+
          "ORDER BY amount DESC NULLs last "+
          "LIMIT 10 offset " + offsetProduct + " ;");

        rs_product_check = stmt4.executeQuery(
          "SELECT p.id "+
          "as amount "+
          "FROM products p left outer join orders o on p.id = o.product_id "+ 
          "where p.category_id = "+
          "(select id from categories where name = "+"\'"+categoryOption+"\'"+") "+
          "GROUP BY p.name, p.id "+
          "ORDER BY amount DESC NULLs last "+
          "LIMIT 10 offset " + offsetProductInc + " ;");
      }
    }
// ============================  Product alphabetical ============================ //
    else{ 
      if(categoryOption.equals("all")){
        rs_product = stmt2.executeQuery(
          "select p.id, Left(p.name,10),round(cast(sum(o.quantity * o.price) as numeric),2) as amount " + 
          "from products p left outer join orders o on p.id = o.product_id " +
          "where o.is_cart = false "+
          "group by p.id order by p.name ASC " +
          "limit 10 offset " + offsetProduct + " ;" );

        rs_product_check = stmt4.executeQuery(
          "select p.id " + 
          "from products p left outer join orders o on p.id = o.product_id " +
          "where o.is_cart = false "+
          "group by p.id order by p.name ASC " +
          "limit 10 offset " + offsetProductInc + " ;" );
      }
      else{
        rs_product = stmt2.executeQuery(
          "select p.id, Left(p.name,10),round(cast(sum(o.quantity * o.price) as numeric),2) as amount " +  
          "from products p left outer join orders o on p.id = o.product_id " +  
          "where o.is_cart = false and p.category_id = " +
          "(select c.id from categories c where c.name = "+ "\'" +categoryOption + "\'"+ ") " +
          "group by p.id order by p.name ASC "+ 
          "limit 10 offset " + offsetProduct + " ;" );

        rs_product_check = stmt4.executeQuery(
        "select p.id " +  
          "from products p left outer join orders o on p.id = o.product_id " +  
          "where o.is_cart = false and p.category_id = " +
          "(select c.id from categories c where c.name = "+ "\'" +categoryOption + "\'"+ ") " +
          "group by p.id order by p.name ASC "+ 
          "limit 10 offset " + offsetProductInc + " ;" );
      } 
    }   
// ============================  State and Top_K ============================ //
    if(rowOption.equals("states")){
      if(orderOption.equals("top_k") ){ 
        rs_stateOrCustomer = stmt.executeQuery(
          "select distinct state, round(cast(sum(o.quantity*o.price) as numeric),2) "+ 
          "as amount "+
          "from users u left outer join orders o on u.id = o.user_id group by state "+
          "order by amount desc nulls last limit 20 offset "+ offsetCS + " ;");

        rs_stateOrCustomer_check = stmt5.executeQuery(
          "select distinct state "+ 
          "as amount "+
          "from users u left outer join orders o on u.id = o.user_id group by state "+
          "order by amount desc nulls last limit 20 offset "+ offsetCSInc + " ;");
      }
// ============================  State and Alphabetical ============================ //
      else{ //states alphabetical
        rs_stateOrCustomer = stmt.executeQuery(
        "select u.state, round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
        "from users u left outer join orders o on u.id = o.user_id "+
        "group by u.state order by state asc limit 20 offset "+ offsetCS + " ;");

        rs_stateOrCustomer_check = stmt5.executeQuery(
        "select u.state "+
        "from users u left outer join orders o on u.id = o.user_id "+
        "group by u.state order by state asc limit 20 offset "+ offsetCSInc + " ;");

      }
      cell_amount = conn.prepareStatement(
        "select u.state, round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+ 
        "from users u left outer join orders o on o.user_id = u.id "+ 
        "where o.product_id = ? and u.state = ? and o.is_cart = false "+ 
        "group by u.state ;");
    }
// ============================  Customer and Top_K ============================ //
    else{ //selected customer
      if(orderOption.equals("top_k") ){ //customer, top-k
        rs_stateOrCustomer = stmt.executeQuery(
          "select u.id, name,round(cast(sum(o.quantity*o.price) as numeric),2) "+ 
          "as amount "+
          "from users u left outer join orders o on u.id = o.user_id group by u.id "+
          "order by amount desc nulls last limit 20 offset "+ offsetCS + " ;");

        rs_stateOrCustomer_check = stmt5.executeQuery(
          "select u.id "+ 
          "as amount "+
          "from users u left outer join orders o on u.id = o.user_id group by u.id "+
          "order by amount desc nulls last limit 20 offset "+ offsetCSInc + " ;"); 
      }
// ============================  Customer and Alphabetical ============================ //
      else{ //customer, alphabetical
        rs_stateOrCustomer = stmt.executeQuery(
        "select u.id, u.name,round(cast(sum(o.quantity * o.price) as numeric),2) as amount "+
        "from users u left outer join orders o on u.id = o.user_id "+
        "group by u.id order by u.name asc limit 20 offset "+ offsetCS + " ;" );

        rs_stateOrCustomer_check = stmt5.executeQuery(
        "select u.id, u.name "+
        "from users u left outer join orders o on u.id = o.user_id "+
        "group by u.id order by u.name asc limit 20 offset "+ offsetCSInc + " ;" );
      }
      cell_amount = conn.prepareStatement(
        "select round(cast((o.price*o.quantity) as numeric),2) as amount "+
        "from orders o "+
        "where o.product_id = ? and o.user_id = ? and o.is_cart = false ");
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
  <% if (offsetCS == 0 && offsetProduct ==0 ) {%>
  <form action="orders.jsp" method="POST">
    <select name = "row_option" >
      <%if(rowOption!= ""&& 
            rowOption.equals("states")) {%>
          <option value = "customers">Customers</option>
          <option selected value = "states">States</option>
       <%} 
       else{%>
          <option selected value = "customers">Customers</option>
          <option value = "states">States</option>
       <%}%>
    </select>

    <select name = "order_option" >
       <% if(orderOption !="" && 
            orderOption.equals("top_k")) {%>
          <option value = "alphabetical">Alphabetical</option>
          <option selected value = "top_k">Top-K</option>      
       <%} 
       else{%>
          <option selected value = "alphabetical">Alphabetical</option>
          <option value = "top_k">Top-K</option>
       <%}%>
    </select>
   

    <select name = "category_option" >
      <option value = "all">All</option>
      <%while(rs_categories.next()){
          String category = rs_categories.getString("name");
          if(categoryOption != "" && 
            categoryOption.equals(category)) {%>
            <option selected value="<%=category%>"><%=category%></option>
          <%}
          else{%>
            <option value="<%=category%>"><%=category%></option>
          <%}
        }%>
    </select>

    
    <input type="submit" value = "Run Query"/>
  </form>
  <%}%>

  <%if ("POST".equalsIgnoreCase(request.getMethod())) { %>
  <div> 
    <%if( rs_product_check.next()){ %>
      <form action= "orders.jsp" method="POST"> 
        <input type="hidden" type="number" name="addProduct" value="<%=offsetProductInc%>">
        <input type="submit" value = "Next 10 Products"/>
      </form> 
    <%}%>

    <%if( rs_stateOrCustomer_check.next()){ %>
      <form action= "orders.jsp" method="POST"> 
        <input type="hidden" type="number" name="addCS" value="<%=offsetCSInc%>">
        <%if (rowOption.equals("customers")){ %>
          <input type="submit" value = "Next 20 Customers"/>
        <%}
          else{ %>
          <input type="submit" value = "Next 20 States"/>
        <%}%>

      </form>
    <%}%> 
  </div>

  <%}%>
</div>


<table class="table table-striped"><%
  if(rs_stateOrCustomer!=null && rs_product!=null && cell_amount!=null) { 
    String displayOption = ( (rowOption.equals("states"))? "State | Product" : "Customer | Product");%>
    <th><%= displayOption %></th>
    <%
      ArrayList productList = new ArrayList(); 
      
      while(rs_product.next()){
        String productSpending = 
            ((rs_product.getString("amount") == null) ? "0" : 
            rs_product.getString("amount"));

        %>
        <th><%=rs_product.getString("left") + " (" + productSpending + ")"%></th>
        <%productList.add(rs_product.getString("id"));   
      }

      ResultSet salesAmount = null;

      while (rs_stateOrCustomer.next()) { 
        if (rowOption.equals("customers")){%>
        <tr>
          <%String amount = 
            ((rs_stateOrCustomer.getString("amount") == null) ? "0" : 
            rs_stateOrCustomer.getString("amount"));%>
          <td><b><%=rs_stateOrCustomer.getString("name")+ " ("+
            amount+")"%></b></td>

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

      else if (rowOption.equals("states")) {%>
        <tr>
        <%String amount = 
          ((rs_stateOrCustomer.getString("amount") == null) ? "0" : 
          rs_stateOrCustomer.getString("amount"));%>
        <td><b><%=rs_stateOrCustomer.getString("state")+ " ($ "+
          amount+")"%></b></td>

      <%for(int counter = 0; counter < productList.size(); counter++){

          cell_amount.setInt(1, Integer.valueOf((String)productList.get(counter))); 
          cell_amount.setString(2, rs_stateOrCustomer.getString("state"));
      
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

    }
} %>
</table>



</body>
</html>