<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.lang.Integer"  %>
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
    int _section_id = request.getParameter("section_id")==null ? 0 : Integer.parseInt(request.getParameter("section_id"));
    String _course_id = request.getParameter("course_id");    //  fk
    String _quarter = request.getParameter("quarter");        // fk
    String _title = request.getParameter("title");
    String _faculty_name = request.getParameter("faculty_name");  // fk
    int _available_seats = request.getParameter("available_seats")==null ? 0 : Integer.parseInt(request.getParameter("available_seats"));
    int _total_seats = request.getParameter("total_seats")==null ? 0 : Integer.parseInt(request.getParameter("total_seats"));

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);
      
      PreparedStatement pstmt = conn.prepareStatement(
          "insert into classes (course_id, quarter, title, faculty_name, available_seats, total_seats) values (?,?,?,?,?,?)");
      
      pstmt.setString(1, _course_id);
      pstmt.setString(2, _quarter);
      pstmt.setString(3, _title);
      pstmt.setString(4, _faculty_name);
      pstmt.setInt(5, _available_seats);
      pstmt.setInt(6, _total_seats);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update classes set course_id=?, quarter=?, title=?, faculty_name=?, available_seats=?, total_seats=? where section_id=?");
      
      pstmt.setString(1, _course_id);
      pstmt.setString(2, _quarter);
      pstmt.setString(3, _title);
      pstmt.setString(4, _faculty_name);
      pstmt.setInt(5, _available_seats);
      pstmt.setInt(6, _total_seats);
      pstmt.setInt(7, _section_id);     // fill in the student_id wildcard
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from classes where section_id=?");

      pstmt.setInt(1, _section_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=classes");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from classes order by course_id");

    Statement stmt_courses = conn.createStatement();
    ResultSet rs_courses = stmt_courses.executeQuery("select course_id from courses order by course_id");
    ArrayList<String> course_ids = new ArrayList<String>();
    while (rs_courses.next()) {
      course_ids.add(rs_courses.getString("course_id"));
    }

    Statement stmt_faculties = conn.createStatement();
    ResultSet rs_faculties = stmt_faculties.executeQuery("select faculty_name from faculties order by faculty_name");
    ArrayList<String> faculty_names = new ArrayList<String>();
    while (rs_faculties.next()) {
      faculty_names.add(rs_faculties.getString("faculty_name"));
    }
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var title_insert = document.getElementById("title_insert"); 
  var available_seats_insert = document.getElementById("available_seats_insert");
  var total_seats_insert = document.getElementById("total_seats_insert");
  var insertButton = document.getElementById("insert_button");
  
  let invalid = title_insert.value == "" ||  available_seats_insert < 0 || total_seats_insert < 0;

  if (invalid) {
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
    <th>course ID</th>
    <th>quarter</th>
    <th>title</th>
    <th>faculty name</th>
    <th>avaliable seats</th>
    <th>total seats</th>
  </tr>

  <tr>
    <form action="classes.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td></td>
      <%-- <td><input type="text" name="course_id" size="12" id="course_id_insert" onkeyup="checkInsert()"></td> --%>
      <td>
        <select name="course_id">
          <% for (String course_id : course_ids) { %>
            <option value="<%= course_id %>"><%= course_id %></option>
          <% } %>
        </select>
      </td>
      <td><input type="text" name="quarter" size="12" id="quarter_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="title" size="12" id="title_insert" onkeyup="checkInsert()"></td>
      <%-- <td><input type="text" name="faculty_name" size="12" id="faculty_name_insert" onkeyup="checkInsert()"></td> --%>
      <td>
        <select name="faculty_name">
          <% for (String faculty_name : faculty_names) { %>
            <option value="<%= faculty_name %>"><%= faculty_name %></option>
          <% } %>
        </select>
      </td>
      <td><input type="text" name="available_seats" size="12" id="available_seats_insert" onkeyup="checkInsert()" value="0"></td>
      <td><input type="text" name="total_seats" size="12" id="total_seats_insert" onkeyup="checkInsert()" value="0"></td>
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    int section_id = rs.getInt("section_id");
    String course_id = rs.getString("course_id");
    String quarter = rs.getString("quarter");
    String title = rs.getString("title");
    String faculty_name = rs.getString("faculty_name");
    int available_seats = rs.getInt("available_seats");
    int total_seats = rs.getInt("total_seats");
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
  <form action="classes.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="section_id" value="<%= section_id %>">
    <td><input type="number" class="<%= rowN%>" name="section_id" size="12" value="<%= section_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="course_id" size="12" value="<%= course_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="quarter" size="12" value="<%= quarter %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="title" size="12" value="<%= title %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="faculty_name" size="12" value="<%= faculty_name %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="available_seats" size="12" value="<%= available_seats %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="number" class="<%= rowN%>" name="total_seats" size="12" value="<%= total_seats %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="classes.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="section_id" value="<%= section_id %>">
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
    out.println(e);
  }
  catch (Exception e) {
    out.println(e);
  }

%>