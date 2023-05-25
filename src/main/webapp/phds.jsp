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
    String _fname = request.getParameter("fname");
    String _mname = request.getParameter("mname");
    String _lname = request.getParameter("lname");
    String _ssn = request.getParameter("ssn");
    String _residency = request.getParameter("residency");
    String _department = request.getParameter("department");
    String _is_candidate = request.getParameter("is_candidate");
      _is_candidate = _is_candidate != null ? "Y" : "N";
    String _advisor = request.getParameter("advisor");

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into phds values (?, ?, ?, ?, ?, ?, ?, ?, ?)");
      
      pstmt.setString(1, _student_id);
      pstmt.setString(2, _fname);
      pstmt.setString(3, _mname);
      pstmt.setString(4, _lname);
      pstmt.setString(5, _ssn);
      pstmt.setString(6, _residency);
      pstmt.setString(7, _department);
      pstmt.setString(8, _is_candidate);
      pstmt.setString(9, _advisor);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update phds set fname=?, mname=?, lname=?, ssn=?, residency=?, department=?, is_candidate=?, advisor=? where student_id=?");
      
      pstmt.setString(1, _fname);
      pstmt.setString(2, _mname);
      pstmt.setString(3, _lname);
      pstmt.setString(4, _ssn);
      pstmt.setString(5, _residency);
      pstmt.setString(6, _department);
      pstmt.setString(7, _is_candidate);
      pstmt.setString(8, _advisor);
      pstmt.setString(9, _student_id);     // fill in the student_id wildcard
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from phds where student_id=?");

      pstmt.setString(1, _student_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=phds");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from phds order by student_id");

    Statement stmt_dept = conn.createStatement();
    ResultSet rs_dept = stmt_dept.executeQuery("select * from departments order by department");
    ArrayList<String> depts = new ArrayList<String>();
    depts.add("");  // empty option for the select tag
    while (rs_dept.next()) {
      depts.add(rs_dept.getString("department"));
    }
%>


<%-- JS (rocks!) to validify form inputs before insertion  --%>
<script>
function checkInsert() {
  var studentIdInsert = document.getElementById("student_id_insert");
  var fnameInsert = document.getElementById("fname_insert");
  var lnameInsert = document.getElementById("lname_insert");
  var ssnInsert = document.getElementById("ssn_insert");
  var departmentInsert = document.getElementById("department_insert");

  var insertButton = document.getElementById("insert_button");
  
  if (studentIdInsert.value == "" || fnameInsert.value == "" || lnameInsert.value == "" || ssnInsert.value == "" || departmentInsert.value == "") {
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
    <th>First Name</th>
    <th style="color: gray;">Middle Name</th>
    <th>Last Name</th>
    <th>SSN</th>
    <th>Residency</th>
    <th>Department</th>
    <th>Candidacy</th>
    <th>Advisor</th>
  </tr>

  <tr>
    <form action="phds.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="student_id" size="12" id="student_id_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="fname" size="12" id="fname_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="mname" size="12"></td>
      <td><input type="text" name="lname" size="12" id="lname_insert" onkeyup="checkInsert()"></td>
      <td><input type="text" name="ssn" size="12" id="ssn_insert" onkeyup="checkInsert()"></td>
      <td><select name="residency" >
          <option value="CA resident">CA resident</option>
          <option value="Non-CA US">Non-CA US</option>
          <option value="Foreign">Foreign</option>
          </select>
      </td>
      <%-- <td><input type="text" name="department" size="20" id="department_insert" onkeyup="checkInsert()"></td> --%>
      <td><select name="department" id="department_insert" onchange="checkInsert()">
          <% for (String dept : depts) { %>
            <option value="<%= dept %>"><%= dept %></option>
          <% } %>
          </select>
      </td>
      <td><input type="checkbox" name="is_candidate" value="Y">Is Candidate</td>
      <td><input type="text" name="advisor" size="12"></td>
      
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String student_id = rs.getString("student_id");
    String fname = rs.getString("fname");
    String mname = rs.getString("mname");
    String lname = rs.getString("lname");
    String ssn = rs.getString("ssn");
    String residency = rs.getString("residency");
    String department = rs.getString("department");
    boolean is_cand = rs.getBoolean("is_candidate");
    String advisor = rs.getString("advisor");
%>

<%-- JS to validify form inputs before updating each row --%>
<script>
function tickIt(row) {
  var updateButton = document.getElementById("update_button_" + row);
  updateButton.disabled = false;
}

function checkUpdate(row) {
  
  var entries = document.getElementsByClassName(row);
  var updateButton = document.getElementById("update_button_" + row);

  if (updateButton.disabled == false) {
    return;
  }
  
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
  <form action="phds.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="student_id" value="<%= student_id %>">
    <td><input type="text" class="<%= rowN%>" name="student_id" size="12" value="<%= student_id %>" readonly onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="fname" size="12" value="<%= fname %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" name="mname" size="12" value="<%= mname %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="lname" size="12" value="<%= lname %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="text" class="<%= rowN%>" name="ssn" size="12" value="<%= ssn %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td>
      <select name="residency" onchange="checkUpdate(<%= rowN%>)">
        <option value="CA resident" <%= residency.equals("CA resident") ? "selected" : "" %>>CA resident</option>
        <option value="Non-CA US" <%= residency.equals("Non-CA US") ? "selected" : "" %>>Non-CA US</option>
        <option value="Foreign" <%= residency.equals("Foreign") ? "selected" : "" %>>Foreign</option>
      </select>
    </td>
    <td>
      <select name="department" class="<%= rowN%>" onchange="checkUpdate(<%= rowN%>)">
        <% for (String dept : depts) { %>
          <option value="<%= dept %>" <%= department.equals(dept) ? "selected" : "" %>><%= dept %></option>
        <% } %>
      </select>
    </td>
    <td><input type="checkbox" name="is_candidate" value="Y"  <%= (is_cand) ? "checked" : "" %> onchange="tickIt(<%= rowN%>)"></td>
    <td><input type="text" name="advisor" size="12" value="<%= advisor %>" onkeyup="checkUpdate(<%= rowN%>)"></td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update" disabled></td>
  </form>
  
  <form action="phds.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="student_id" value="<%= student_id %>">
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