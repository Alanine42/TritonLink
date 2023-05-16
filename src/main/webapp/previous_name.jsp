<%@ page language="java" import="java.sql.*"  %>


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
    String _prev = request.getParameter("prev");
    String _curr = request.getParameter("curr");

    String action = request.getParameter("action");                                      

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into previous_name values (?, ?)");
      
      pstmt.setString(1, _prev);
      pstmt.setString(2, _curr);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from previous_name where prev=? and curr=?");

      pstmt.setString(1, _prev);
      pstmt.setString(2, _curr);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=previous_name");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from previous_name order by prev, curr");
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var prev_insert = document.getElementById("prev_insert");
  var curr_insert = document.getElementById("curr_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (prev_insert.value == "" || curr_insert.value == "") {
    insertButton.disabled = true;
    //insertButton.style.opacity = "0.5"; // dim the button
  } else {
    insertButton.disabled = false;
    //insertButton.style.opacity = "1"; // reset the button opacity
  }

  if (grade_options_insert.value == "S_U")
  {
    units_insert.value = 0;
  }
}
</script>
<%-- <br><code>Presentation & Insertion </code> --%>
<table>
  <tr>
    <th>Previous</th>
    <th>Current</th>
  </tr>

  <tr>
    <form action="previous_name.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="prev" size="12" id="prev_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="curr" size="12" id="curr_insert" onkeyup="checkInsert()"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String prev = rs.getString("prev");
    String curr = rs.getString("curr");
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
  <form action="previous_name.jsp" method="get">      
    <input type="hidden" name="action" value="delete">
    <td><input name="prev" value="<%= prev %>"></td>
    <td><input name="curr" value="<%= curr %>"></td>
    <td><input type="submit" value="Delete"></td>
  </form>
</tr>

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