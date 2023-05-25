<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList"  %>


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
    int _section_id = 0;
    if (request.getParameter("section_id") != null) {
      _section_id = Integer.parseInt(request.getParameter("section_id"));
    }
    String _type = request.getParameter("type");
    String _days = request.getParameter("days");
    String _time = request.getParameter("time");
    String _room_id = request.getParameter("room_id");
    String _mandatory = request.getParameter("mandatory");

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);
      
      PreparedStatement pstmt = conn.prepareStatement(
          "insert into meetings values (?, ?, ?, ?, ?, ?)");
      
      pstmt.setInt(1, _section_id);
      pstmt.setString(2, _type);
      pstmt.setString(3, _days);
      pstmt.setString(4, _time);
      pstmt.setString(5, _room_id);
      pstmt.setString(6, _mandatory);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update meetings set days=?, time=?, room_id=?, mandatory=? where section_id=? and type=?");
      
      pstmt.setString(1, _days);
      pstmt.setString(2, _time);
      pstmt.setString(3, _room_id);
      pstmt.setString(4, _mandatory);
      pstmt.setInt(5, _section_id);
      pstmt.setString(6, _type);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from meetings where section_id=?, type=?");

      pstmt.setInt(1, _section_id);
      pstmt.setString(2, _type);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=meetings");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from meetings order by section_id, type");

    Statement stmt_section = conn.createStatement();
    ResultSet rs_section = stmt_section.executeQuery("select section_id from classes order by section_id");
    ArrayList<Integer> section_ids = new ArrayList<Integer>();
    while (rs_section.next()) {
      section_ids.add(rs_section.getInt("section_id"));
    }

    
    
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var days_insert = document.getElementById("days_insert");
  var time_insert = document.getElementById("time_insert");
  var room_id_insert = document.getElementById("room_id_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (date_insert.value == "" || time_insert.value == "" || room_id_insert.value == "") {
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
    <th>section ID</th>
    <th>type</th>
    <th>days</th>
    <th>time</th>
    <th>room ID</th>
    <th>mandatory</th>
  </tr>

  <tr>
    <form action="meetings.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td>
        <select name="section_id">
          <% for (int section_id: section_ids) { %>
            <option value="<%= section_id %>"><%= section_id %></option>
          <% } %>
        </select>
      </td>

      <td>
        <select name="type">
          <option value="LE">LE</option>
          <option value="DI">DI</option>
          <option value="LAB">LAB</option>
        </select>
      </td>

      <td><input type="text" name="days" size="12" id="days_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="time" size="12" id="time_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="room_id" size="12" id="room_id_insert" onkeyup="checkInsert()"></td>
      <td>
        <select name="mandatory">
          <option value="yes">yes</option>
          <option value="no">no</option>
        </select>
      </td>
      <td><input type="submit" value="Insert" id="insert_button"></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    int section_id = rs.getInt("section_id");
    String type = rs.getString("type");
    String days = rs.getString("days");
    String time = rs.getString("time");
    String room_id = rs.getString("room_id");
    String mandatory = rs.getString("mandatory");
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
  <form action="meetings.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <input type="hidden" name="type" value="<%= type %>">
    <td><input type="number" class="<%= rowN%>" name="section_id" size="12" value="<%= section_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    
    <td>
      <select name="type" onchange="checkUpdate(<%= rowN%>)">
        <option value="LE" <%= (type.equals("LE")) ? "selected" : "" %>>LE</option>
        <option value="DI" <%= (type.equals("DI")) ? "selected" : "" %>>DI</option>
        <option value="LAB" <%= (type.equals("LAB")) ? "selected" : "" %>>LAB</option>
      </select>
    </td>
    
    <td><input type="text" class="<%= rowN%>" name="days" size="12" value="<%= days %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="time" size="12" value="<%= time %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="room_id" size="12" value="<%= room_id %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="mandatory" size="12" value="<%= mandatory %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="meetings.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <input type="hidden" name="type" value="<%= type %>">
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
    rs_section.close();
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

