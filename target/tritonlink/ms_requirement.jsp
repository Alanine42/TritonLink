<%@ page language="java" import="java.sql.*" %>


<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/postgres", "postgres", "postgres");
    out.println("Connected to Postgres!");
// [!] un/comment the line below to get syntax highlighting for below html codes. 
      //}
%>  

<%-- <br><code> Insertion, Update, Delete </code> --%>
<%
    // Get all the parameters from the form, enforce the non-null's
    String _concentration = request.getParameter("concentration");
    int _min_units = 0;
    if (request.getParameter("min_units") != null) {
      _min_units = Integer.parseInt(request.getParameter("min_units"));
    }

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into ms_requirement values (?, ?)");
      
      pstmt.setString(1, _concentration);
      pstmt.setInt(2, _min_units);
      
      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update ms_requirement set min_units=? where concentration=?");
      
      pstmt.setInt(1, _min_units);
      pstmt.setString(2, _concentration);     // fill in the student_id wildcard
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from ms_requirement where concentration=?");

      pstmt.setString(1, _concentration);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=ms_requirement");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from ms_requirement order by concentration");
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var concentration_insert = document.getElementById("concentration_insert");
  var min_units_insert = document.getElementById("min_units_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (concentration_insert.value == "" || min_units_insert.value == 0) {
    insertButton.disabled = true;
    //insertButton.style.opacity = "0.5"; // dim the button
  } else {
    insertButton.disabled = false;
    //insertButton.style.opacity = "1"; // reset the button opacity
  }
}
</script>
<%-- <br><code>Presentation & Insertion </code> --%>
<table>
  <tr>
    <th>concentration</th>
    <th>min units</th>
  </tr>

  <tr>
    <form action="ms_requirement.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="concentration" size="12" id="concentration_insert" onkeyup="checkInsert()"></td>
      <td><input type="number" name="min_units" size="12" id="min_units_insert" onkeyup="checkInsert()" value="0"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String concentration = rs.getString("concentration");
    int min_units = rs.getInt("min_units");
%>

<%-- JS to validify form inputs before updating each row --%>
<script>
function checkUpdate(row) {
  var entries = document.getElementsByClassName(row);
  var updateButton = document.getElementById("update_button_" + row);
  
  var bad = false;
  for (var ent of entries) {
    if (ent.value == "") {
      bad = true;
    }
  }

  if (bad) {
    updateButton.disabled = true;
    //updateButton.style.opacity = "0.5"; // dim the button
  } else {
    updateButton.disabled = false;
    //updateButton.style.opacity = "1"; // reset the button opacity
  }
}
</script>

<%-- New: presenting the rows with edit/delete --%>
<tr>
  <form action="ms_requirement.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="concentration" value="<%= concentration %>">
    <td><input type="text" class="<%= rowN%>" name="concentration" size="12" value="<%= concentration %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="min_units" size="12" value="<%= min_units %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="ms_requirement.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <td><input type="hidden" name="concentration" value="<%= concentration %>"></td>
    <td><input type="submit" value="Delete"></td>
  </form>
</tr>


<%-- Old: just presenting the rows (No edit/delete) --%>
  <%-- <tr>
    <td><%= req_id %></td>
    <td><%= degree %></td>
    <td><%= course_type %></td>
    <td><%= min_units %></td>
  </tr> --%>
  
<%
  }
%>


</table>



<%-- <br><code>Close connection code</code> --%>
<%
    rs.close();
    stmt.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e.getMessage());
  }
  catch (Exception e) {
    out.println(e.getMessage());
  }

%>