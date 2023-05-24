<%@ page language="java" import="java.sql.*" %>


<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/postgres", "postgres", "postgres");
    // out.println("Connected to Postgres!");
// [!] un/comment the line below to get syntax highlighting for below html codes. 
      //}
%>  

<%-- <br><code> Insertion, Update, Delete </code> --%>
<%
    // Get all the parameters from the form, enforce the non-null's
    int _req_id = 0;
    if (request.getParameter("req_id") != null) {
      _req_id = Integer.parseInt(request.getParameter("req_id"));
    }
    String _degree = request.getParameter("degree");
    String _course_type = request.getParameter("course_type");
    int _min_units = 0;
    if (request.getParameter("min_units") != null) {
      _min_units = Integer.parseInt(request.getParameter("min_units"));
    }

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into bs_requirement (degree, course_type, min_units) values (?, ?, ?)");
      
      pstmt.setString(1, _degree);
      pstmt.setString(2, _course_type);
      pstmt.setInt(3, _min_units);
      
      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update bs_requirement set degree=?, course_type=?, min_units=? where req_id=?");
      
      pstmt.setString(1, _degree);
      pstmt.setString(2, _course_type);
      pstmt.setInt(3, _min_units);
      pstmt.setInt(4, _req_id);     // fill in the student_id wildcard
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from bs_requirement where req_id=?");

      pstmt.setInt(1, _req_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=bs_requirement");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from bs_requirement order by degree");
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var degree_insert = document.getElementById("degree_insert");
  var min_units_insert = document.getElementById("min_units_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (degree_insert.value == "" || min_units_insert.value == 0) {
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
    <th>req id</th>
    <th>degree</th>
    <th>course type</th>
    <th>min units</th>
  </tr>

  <tr>
    <form action="bs_requirement.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td></td>
      <td><input type="text" name="degree" size="12" id="degree_insert" onkeyup="checkInsert()"></td>
      <td><select name="course_type" >
          <option value="core">core</option>
          <option value="elective">elective</option>
          <option value="lower">lower</option>
          <option value="technical_electives">technical electives</option>
          </select>
      </td>
      <td><input type="number" name="min_units" size="12" id="min_units_insert" onkeyup="checkInsert()" value="0"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    int req_id = rs.getInt("req_id");
    String degree = rs.getString("degree");
    String course_type = rs.getString("course_type");
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
  <form action="bs_requirement.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="req_id" value="<%= req_id %>">
    <td><input type="number" class="<%= rowN%>" name="req_id" size="12" value="<%= req_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="degree" size="12" value="<%= degree %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td>
      <select name="course_type" onchange="checkUpdate(<%= rowN%>)">
        <option value="core" <%= course_type.equals("core") ? "selected" : "" %>>core</option>
        <option value="elective" <%= course_type.equals("elective") ? "selected" : "" %>>elective</option>
        <option value="lower" <%= course_type.equals("lower") ? "selected" : "" %>>lower</option>
        <option value="technical_electives" <%= course_type.equals("technical_electives") ? "selected" : "" %>>technical electives</option>
      </select>
    </td>
    <td><input type="number" class="<%= rowN%>" name="min_units" size="12" value="<%= min_units %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="bs_requirement.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <td><input type="hidden" name="req_id" value="<%= req_id %>"></td>
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
    out.println("<br><br><h1>Please click on the brower's back button</h1><br>");
  }
  catch (Exception e) {
    out.println(e.getMessage());
    out.println("<br><br><h1>Please click on the brower's back button</h1><br>");
  }

%>