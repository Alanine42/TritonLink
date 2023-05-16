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
    String _room_id = request.getParameter("room_id");
    int _max_occupants = 0;
    if (request.getParameter("max_occupants") != null) 
    {
      _max_occupants = Integer.parseInt(request.getParameter("max_occupants"));
    }
    String _college = request.getParameter("college");
    
    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into classroom values (?, ?, ?)");
      
      pstmt.setString(1, _room_id);
      pstmt.setInt(2, _max_occupants);
      pstmt.setString(3, _college);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update classroom set max_occupants=?, college=? where room_id=?");
      
      pstmt.setInt(1, _max_occupants);
      pstmt.setString(2, _college);
      pstmt.setString(3, _room_id);     // fill in the student_id wildcard
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from classroom where room_id=?");

      pstmt.setString(1, _room_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=classroom");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from classroom order by room_id");
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var room_id_insert = document.getElementById("room_id_insert");
  var max_occupants_insert = document.getElementById("max_occupants_insert");
  var insertButton = document.getElementById("insert_button");
  
  if (room_id_insert.value == "" || max_occupants_insert.value == 0) {
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
    <th>room id</th>
    <th>max occupants</th>
    <th>college</th>
  </tr>

  <tr>
    <form action="classroom.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="room_id" size="12" id="room_id_insert" onkeyup="checkInsert()"></td>
      <td><input type="number" name="max_occupants" size="12" id="max_occupants_insert" onkeyup="checkInsert()" value="0"></td>
      <td>
        <select name="college">
          <option value="Revelle">Revelle</option>
          <option value="John Muir">John Muir</option>
          <option value="Thurgood Marshall">Thurgood Marshall</option>
          <option value="Earl Warren">Earl Warren</option>
          <option value="Eleanor Roosevelt">Eleanor Roosevelt</option>
          <option value="Sixth">Sixth</option>
          <option value="Seventh">Seventh</option>
        </select>
      </td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String room_id = rs.getString("room_id");
    int max_occupants = rs.getInt("max_occupants");
    String college = rs.getString("college");
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
  <form action="classroom.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="room_id" value="<%= room_id %>">
    <td><input type="text" class="<%= rowN%>" name="room_id" size="12" value="<%= room_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="max_occupants" size="12" value="<%= max_occupants %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td>
      <select name="college" onchange="checkUpdate(<%= rowN%>)">
        <option value="Revelle" <%= (college.equals("Revelle")) ? "selected" : "" %>>Revelle</option>
        <option value="John Muir" <%= (college.equals("John Muir")) ? "selected" : "" %>>John Muir</option>
        <option value="Thurgood Marshall" <%= (college.equals("Thurgood Marshall")) ? "selected" : "" %>>Thurgood Marshall</option>
        <option value="Earl Warren" <%= (college.equals("Earl Warren")) ? "selected" : "" %>>Earl Warren</option>
        <option value="Eleanor Roosevelt" <%= (college.equals("Eleanor Roosevelt")) ? "selected" : "" %>>Eleanor Roosevelt</option>
        <option value="Sixth" <%= (college.equals("Sixth")) ? "selected" : "" %>>Sixth</option>
        <option value="Seventh" <%= (college.equals("Seventh")) ? "selected" : "" %>>Seventh</option>
      </select>
    </td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="classroom.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="room_id" value="<%= room_id %>">
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