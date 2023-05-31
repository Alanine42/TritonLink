<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList" %>

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
    String _student_id = request.getParameter("student_id");
    int _section_id = 0;
    if (request.getParameter("section_id") != null) {
      _section_id = Integer.parseInt(request.getParameter("section_id"));
    }
    int _unit = 0;
    if (request.getParameter("unit") != null) {
      _unit = Integer.parseInt(request.getParameter("unit"));
    }
    String _grade = request.getParameter("grade");
    
    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);
      
      PreparedStatement pstmt = conn.prepareStatement(
          "insert into classes_taken values (?, ?, ?, ?)");
      
      pstmt.setString(1, _student_id);
      pstmt.setInt(2, _section_id);
      pstmt.setInt(3, _unit);
      pstmt.setString(4, _grade);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update classes_taken set unit=?, grade=? where student_id=? and section_id=?");
      
      pstmt.setInt(1, _unit);
      pstmt.setString(2, _grade);
      pstmt.setString(3, _student_id);
      pstmt.setInt(4, _section_id);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from classes_taken where student_id=? and section_id=?");

      pstmt.setString(1, _student_id);
      pstmt.setInt(2, _section_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=classes_taken");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from classes_taken order by student_id, section_id");

    Statement stmt_students = conn.createStatement();
    ResultSet rs_students = stmt_students.executeQuery("select student_id from students order by student_id");
    ArrayList<String> student_ids = new ArrayList<String>();
    while (rs_students.next()) {
      student_ids.add(rs_students.getString("student_id"));
    }

    Statement stmt_sections = conn.createStatement();
    ResultSet rs_sections = stmt_sections.executeQuery("select section_id from classes order by section_id");
    ArrayList<Integer> section_ids = new ArrayList<Integer>();
    while (rs_sections.next()) {
      section_ids.add(rs_sections.getInt("section_id"));
    }
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var student_id_insert = document.getElementById("student_id_insert");
  var unit_insert = document.getElementById("unit_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (student_id_insert.value == "" ||  unit_insert.value == 0) {
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
    <th>student ID</th>
    <th>section ID</th>
    <th>unit</th>
    <th>grade</th>
  </tr>

  <tr>
    <form action="classes_taken.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <%-- <td><input type="text" name="student_id" size="12" id="student_id_insert" onkeyup="checkInsert()"></td> --%>
      <td>
        <select name="student_id" id="student_id_insert" onchange="checkInsert()">
          <option value="">--</option>
          <% for (String student_id : student_ids) { %>
            <option value="<%= student_id %>"><%= student_id %></option>
          <% } %>
        </select>
      </td>
      <%-- <td><input type="number" name="section_id" size="12" id="section_id_insert" onkeyup="checkInsert()" value="0"></td> --%>
      <td>
        <select name="section_id" id="section_id_insert" onchange="checkInsert()">
          <option value="0">--</option>
          <% for (Integer section_id : section_ids) { %>
            <option value="<%= section_id %>"><%= section_id %></option>
          <% } %>
        </select>
      </td>
      <td><input type="number" name="unit" size="12" id="unit_insert" onchange="checkInsert()" min="1", max="8" value="0"></td>
      <td><select name="grade" >
        <option value="A+">A+</option>
        <option value="A">A</option>
        <option value="A-">A-</option>
        <option value="B+">B+</option>
        <option value="B">B</option>
        <option value="B-">B-</option>        
        <option value="C+">C+</option>
        <option value="C">C</option>
        <option value="C-">C-</option>        
        <option value="D">D</option>
        <option value="F">F</option>
        <option value="P">P</option>        
        <option value="NP">NP</option>
        <option value="S">S</option>
        <option value="U">U</option>
        <option value="IN">I</option>
        <option value="W">W</option>
        <option value="X">X</option>
        </select>
      </td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String student_id = rs.getString("student_id");
    int section_id = rs.getInt("section_id");
    int unit = rs.getInt("unit");
    String grade = rs.getString("grade");
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
  <form action="classes_taken.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="student_id" value="<%= student_id %>">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <td><input type="text" class="<%= rowN%>" name="student_id" size="12" value="<%= student_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="section_id" size="12" value="<%= section_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="unit" size="12" value="<%= unit %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td>
        <select name="grade" onchange="checkUpdate(<%= rowN%>)">
          <option value="A+" <%= grade.equals("A+") ? "selected" : "" %>>A+</option>
          <option value="A" <%= grade.equals("A") ? "selected" : "" %>>A</option>
          <option value="A-" <%= grade.equals("A-") ? "selected" : "" %>>A-</option>          
          <option value="B+" <%= grade.equals("B+") ? "selected" : "" %>>B+</option>
          <option value="B" <%= grade.equals("B") ? "selected" : "" %>>B</option>
          <option value="B-" <%= grade.equals("B-") ? "selected" : "" %>>B-</option>
          <option value="C+" <%= grade.equals("C+") ? "selected" : "" %>>C+</option>
          <option value="C" <%= grade.equals("C") ? "selected" : "" %>>C</option>
          <option value="C-" <%= grade.equals("C-") ? "selected" : "" %>>C-</option>
          <option value="D" <%= grade.equals("D") ? "selected" : "" %>>D</option>
          <option value="F" <%= grade.equals("F") ? "selected" : "" %>>F</option>
          <option value="P" <%= grade.equals("P") ? "selected" : "" %>>P</option>
          <option value="NP" <%= grade.equals("NP") ? "selected" : "" %>>NP</option>
          <option value="S" <%= grade.equals("S") ? "selected" : "" %>>S</option>
          <option value="U" <%= grade.equals("U") ? "selected" : "" %>>U</option>
          <option value="IN" <%= grade.equals("IN") ? "selected" : "" %>>I</option>
          <option value="W" <%= grade.equals("W") ? "selected" : "" %>>W</option>
          <option value="X" <%= grade.equals("X") ? "selected" : "" %>>X</option>
        </select>
    </td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="classes_taken.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <td><input type="hidden" name="student_id" value="<%= student_id %>"></td>
    <td><input type="hidden" name="section_id" value="<%= section_id %>"></td>
    <td><input type="submit" value="Delete"></td>
  </form>
</tr>


<%-- Old: just presenting the rows (No edit/delete) --%>
  <%-- <tr>
    <td><%= course ID %></td>
    <td><%= section ID %></td>

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
    stmt.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e.getMessage());
    out.println("<br><br><h1>Please click on the browser's back button</h1><br>");
  }
  catch (Exception e) {
    out.println(e.getMessage());
    out.println("<br><br><h1>Please click on the browser's back button</h1><br>");
  }

%>