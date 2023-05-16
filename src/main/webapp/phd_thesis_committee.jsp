<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList" %>


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
    String _faculty1 = request.getParameter("faculty1");
    String _faculty2 = request.getParameter("faculty2");
    String _faculty3 = request.getParameter("faculty3");
    String _facultyOut = request.getParameter("facultyOut");
    String _additional = request.getParameter("additional");
    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into phd_thesis_committee values (?, ?, ?, ?, ?, ?)");
      
      pstmt.setString(1, _student_id);
      pstmt.setString(2, _faculty1);
      pstmt.setString(3, _faculty2);
      pstmt.setString(4, _faculty3);
      pstmt.setString(5, _facultyOut);
      pstmt.setString(6, _additional);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update phd_thesis_committee set faculty1=?, faculty2=?, faculty3=?, facultyOut=?, additional=? where student_id=?");
      
      pstmt.setString(1, _faculty1);
      pstmt.setString(2, _faculty2);
      pstmt.setString(3, _faculty3);
      pstmt.setString(4, _facultyOut);
      pstmt.setString(5, _additional);     // fill in the student_id wildcard
      pstmt.setString(6, _student_id);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from phd_thesis_committee where student_id=?");

      pstmt.setString(1, _student_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=phd_thesis_committee");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from phd_thesis_committee order by student_id");

    Statement stmt_faculty = conn.createStatement();
    ResultSet rs_faculty = stmt_faculty.executeQuery("select * from faculties order by faculty_name");
    ArrayList<String> faculty_names = new ArrayList<String>();
    faculty_names.add("");
    while (rs_faculty.next()) {
      faculty_names.add(rs_faculty.getString("faculty_name"));
    }
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var studentIdInsert = document.getElementById("student_id_insert");
  var insertButton = document.getElementById("insert_button");
  
  if (studentIdInsert.value == "") {
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
    <th>Faculty1</th>
    <th>Faculty2</th>
    <th>Faculty3</th>
    <th>FacultyOut</th>
    <th>Additional</th>
  </tr>

  <tr>
    <form action="phd_thesis_committee.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="student_id" size="12" id="student_id_insert" onkeyup="checkInsert()"></td>
      <%-- <td><input type="text" name="faculty_name" size="12" id="faculty_name_insert" onkeyup="checkInsert()"></td> --%>
      <td>
        <select name="faculty1" id="faculty1_insert" onchange="checkInsert()">
          <% for (String faculty_name : faculty_names) { %>
            <option value="<%= faculty_name %>"><%= faculty_name %></option>
          <% } %>
        </select>
      </td>
      <td>
        <select name="faculty2" id="faculty2_insert" onchange="checkInsert()">
          <% for (String faculty_name : faculty_names) { %>
            <option value="<%= faculty_name %>"><%= faculty_name %></option>
          <% } %>
        </select>
      </td>
      <td>
        <select name="faculty3" id="faculty3_insert" onchange="checkInsert()">
          <% for (String faculty_name : faculty_names) { %>
            <option value="<%= faculty_name %>"><%= faculty_name %></option>
          <% } %>
        </select>
      </td>
        <td>
            <select name="facultyOut" id="facultyOut_insert" onchange="checkInsert()">
            <% for (String faculty_name : faculty_names) { %>
                <option value="<%= faculty_name %>"><%= faculty_name %></option>
            <% } %>
            </select>
        </td>
      <td><input type="text" name="additional" size="12" ></td>
      
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String student_id = rs.getString("student_id");
    String faculty1 = rs.getString("faculty1");
    String faculty2 = rs.getString("faculty2");
    String faculty3 = rs.getString("faculty3");
    String facultyOut = rs.getString("facultyOut");
    String additional = rs.getString("additional");

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
  <form action="phd_thesis_committee.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="student_id" value="<%= student_id %>">
    <td><input type="text" class="<%= rowN%>" name="student_id" size="12" value="<%= student_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="faculty1" size="12" value="<%= faculty1 %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="faculty2" size="12" value="<%= faculty2 %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="faculty3" size="12" value="<%= faculty3 %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="facultyOut" size="12" value="<%= facultyOut %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="additional" size="12" value="<%= additional %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="phd_thesis_committee.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <td><input type="hidden" name="student_id" value="<%= student_id %>"></td>
    <td><input type="submit" value="Delete"></td>
  </form>
</tr>


<%-- Old: just presenting the rows (No edit/delete) --%>
  <%-- <tr>
    <td><%= student_id %></td>
    <td><%= department %></td>
    <td><%= concentrations %></td>
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

    // Triggers constraint ()
  }
  catch (Exception e) {
    out.println(e.getMessage());
  }

%>