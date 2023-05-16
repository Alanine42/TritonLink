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
    String _student_id = request.getParameter("student_id");
    String _from = request.getParameter("from");
    String _to = request.getParameter("to");
    String _status = request.getParameter("status");
    String _reason = request.getParameter("reason");

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into attendance_probation values (?, ?, ?, ?, ?)");
      
      pstmt.setString(1, _student_id);
      pstmt.setString(2, _from);
      pstmt.setString(3, _to);
      pstmt.setString(4, _status);
      pstmt.setString(5, _reason);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update attendance_probation set status=?, reason=? where student_id=? and from_=? and to_=?");
      
      pstmt.setString(1, _status);
      pstmt.setString(2, _reason);
      pstmt.setString(3, _student_id);
      pstmt.setString(4, _from);
      pstmt.setString(5, _to);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from attendance_probation where student_id=? and from_=? and to_=?");

      pstmt.setString(1, _student_id);
      pstmt.setString(2, _from);
      pstmt.setString(3, _to);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=attendance_probation");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from attendance_probation order by student_id");
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var studentIdInsert = document.getElementById("student_id_insert");
  var from_insert = document.getElementById("from_insert");
  var to_insert = document.getElementById("to_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (studentIdInsert.value == "" || from_insert.value == "" || to_insert.value == "" ) {
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
    <th>Student ID</th>
    <th>from</th>
    <th>to</th>
    <th>status</th>
    <th>reason</th>
  </tr>

  <tr>
    <form action="attendance_probation.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="student_id" size="12" id="student_id_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="from" size="12" id="from_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="to" size="12" id="to_insert" onkeyup="checkInsert()"></td>
      <td><select name="status" >
          <option value="attendance">attendance</option>
          <option value="probation">probation</option>
          </select>
      </td>
      <td><input type="text" name="reason" size="12"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String student_id = rs.getString("student_id");
    String from = rs.getString("from_");
    String to = rs.getString("to_");
    String status = rs.getString("status");
    String reason = rs.getString("reason");
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
  <form action="attendance_probation.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="student_id" value="<%= student_id %>">
    <td><input type="text" class="<%= rowN%>" name="student_id" size="12" value="<%= student_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="from" size="12" value="<%= from %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="to" size="12" value="<%= to %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td>
      <select name="status" onchange="checkUpdate(<%= rowN%>)">
        <option value="attendance" <%= status.equals("attendance") ? "selected" : "" %>>attendance</option>
        <option value="probation" <%= status.equals("probation") ? "selected" : "" %>>probation</option>
      </select>
    </td>
    <td><input type="text" name="reason" size="12" value="<%= reason %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="attendance_probation.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="student_id" value="<%= student_id %>">
    <input type="hidden" name="from" value="<%= from %>">
    <input type="hidden" name="to" value="<%= to %>">
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