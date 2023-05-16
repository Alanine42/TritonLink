<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList"  %>


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
    int _section_id = 0;
    if (request.getParameter("section_id") != null) {
      _section_id = Integer.parseInt(request.getParameter("section_id"));
    }
    String _date = request.getParameter("date");
    String _time = request.getParameter("time");
    String _room_id = request.getParameter("room_id");

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);
      
      PreparedStatement pstmt = conn.prepareStatement(
          "insert into review_sessions values (?, ?, ?, ?)");
      
      pstmt.setInt(1, _section_id);
      pstmt.setString(2, _date);
      pstmt.setString(3, _time);
      pstmt.setString(4, _room_id);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update review_sessions set room_id=? where section_id=? and date=? and time=?");
      
      pstmt.setString(1, _room_id);
      pstmt.setInt(2, _section_id);
      pstmt.setString(3, _date);
      pstmt.setString(4, _time);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from review_sessions where section_id=?, date=?, time=?");

      pstmt.setInt(1, _section_id);
      pstmt.setString(2, _date);
      pstmt.setString(3, _time);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=review_sessions");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from review_sessions order by section_id, date, time");

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
  var date_insert = document.getElementById("date_insert");
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
    <th>date</th>
    <th>time</th>
    <th>room ID</th>
  </tr>

  <tr>
    <form action="review_sessions.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <%-- <td><input type="number" name="section_id" size="12" id="section_id_insert" onkeyup="checkInsert()" value="0"></td> --%>
      <td>
        <select name="section_id">
          <% for (int section_id: section_ids) { %>
            <option value="<%= section_id %>"><%= section_id %></option>
          <% } %>
        </select>
      </td>
      <td><input type="text" name="date" size="12" id="date_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="time" size="12" id="time_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="room_id" size="12" id="room_id_insert" onkeyup="checkInsert()"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    int section_id = rs.getInt("section_id");
    String date = rs.getString("date");
    String time = rs.getString("time");
    String room_id = rs.getString("room_id");
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
  <form action="review_sessions.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <input type="hidden" name="date" value="<%= date %>">
    <input type="hidden" name="time" value="<%= time %>">
    <td><input type="number" class="<%= rowN%>" name="section_id" size="12" value="<%= section_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="date" size="12" value="<%= date %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="time" size="12" value="<%= time %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="room_id" size="12" value="<%= room_id %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="review_sessions.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <input type="hidden" name="date" value="<%= date %>">
    <input type="hidden" name="time" value="<%= time %>">
    <td><input type="submit" value="Delete"></td>
  </form>
</tr>


<%-- Old: just presenting the rows (No edit/delete) --%>
  <%-- <tr>
    <td><%= section ID %></td>
    <td><%= course ID %></td>
    <td><%= quarter %></td>
    <td><%= title %></td>
    <td><%= faculty name %></td>
    <td><%= avaliable seats %></td>
    <td><%= total seats %></td>
  </tr> --%>

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
  }
  catch (Exception e) {
    out.println(e.getMessage());
  }

%>