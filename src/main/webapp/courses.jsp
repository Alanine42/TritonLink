<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.lang.Integer"  %>
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
    String _course_id = request.getParameter("course_id");
    String _department = request.getParameter("department");
    String _prereqs = request.getParameter("prereqs");
    String _req_ids = request.getParameter("req_ids");
    String _grade_options = request.getParameter("grade_options");
    String _course_level = request.getParameter("course_level");
    int _unit_low = request.getParameter("unit_low")==null ? 4 : Integer.parseInt(request.getParameter("unit_low"));
    int _unit_high = request.getParameter("unit_high")==null ? 4 : Integer.parseInt(request.getParameter("unit_high"));

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into courses values (?, ?, ?, ?, ?, ?, ?, ?)");
      
      pstmt.setString(1, _course_id);
      pstmt.setString(2, _department);
      pstmt.setString(3, _prereqs);
      pstmt.setString(4, _req_ids);
      pstmt.setString(5, _grade_options);
      pstmt.setString(6, _course_level);
      pstmt.setInt(7, _unit_low);
      pstmt.setInt(8, _unit_high);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update courses set department=?, prereqs=?, req_ids=?, grade_options=?, course_level=?, unit_low=?, unit_high=? where course_id=?");
      
      pstmt.setString(1, _department);
      pstmt.setString(2, _prereqs);
      pstmt.setString(3, _req_ids);
      pstmt.setString(4, _grade_options);
      pstmt.setString(5, _course_level);
      pstmt.setInt(6, _unit_low);
      pstmt.setInt(7, _unit_high);
      pstmt.setString(8, _course_id);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from courses where course_id=?");

      pstmt.setString(1, _course_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=courses");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from courses order by course_id");
    
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
  var courseIdInsert = document.getElementById("course_id_insert");
  var unitL = document.getElementById("unitL");
  var unitH = document.getElementById("unitH");

  var insertButton = document.getElementById("insert_button");
  
  if (courseIdInsert.value == "" || unitL.value == "" || unitH.value == "") {
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
    <th>CourseID</th>
    <th>Department</th>
    <th>Prereqs</th>
    <th>Req IDs</th>
    <th>Grade Options</th>
    <th>Course Level</th>
    <th>Units Range</th>


  </tr>

  <tr>
    <form action="courses.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="course_id" size="8" id="course_id_insert" onkeyup="checkInsert()"></td>
      <td>
        <select name="department" id="department_insert" onchange="checkInsert()">
          <% for (String dept : depts) { %>
            <option value="<%= dept %>"><%= dept %></option>
          <% } %>
        </select>
      </td>
      <td><input type="text" name="prereqs" size="16"></td>
      <td><input type="text" name="req_ids" size="10"></td>
      <td>
        <select name="grade_options">
          <option value="Letter">Letter only</option>
          <option value="S/U">S/U only</option>
          <option value="Letter/S/U">Letter or S/U</option>
        </select>
      </td>
      <td>
        <select name="course_level">
          <option value="lower">Lower</option>
          <option value="upper">Upper</option>
          <option value="graduate">Graduate</option>
        </select>
      </td>
      <td><input type="text" name="unit_low" value="4" size="2" id="unitL" onkeyup="checkInsert()"></td>
      <td><input type="text" name="unit_high" value="4" size="2" id="unitH" onkeyup="checkInsert()"></td>

      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>


<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String course_id = rs.getString("course_id");
    String department = rs.getString("department");
    String prereqs = rs.getString("prereqs");
    String req_ids = rs.getString("req_ids");
    String grade_options = rs.getString("grade_options");
    String course_level = rs.getString("course_level");
    int unit_low = rs.getInt("unit_low");
    int unit_high = rs.getInt("unit_high");  
%>


<tr>
  <form action="courses.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="course_id" value="<%= course_id %>">
    <td><input type="text" name="course_id" size="8" readonly value="<%=course_id%>"></td>
    <td>
      <select name="department" onchange="checkUpdate(<%= rowN%>)">
        <% for (String dept : depts) { %>
          <option value="<%= dept %>" <%= (department.equals(dept)) ? "selected" : "" %>><%= dept %></option>
        <% } %>
      </select>
    </td>
    <td><input type="text" name="prereqs" value="<%= prereqs %>" size="16"></td>
    <td><input type="text" name="req_ids" value="<%= req_ids %>" size="10"></td>
    <td>
      <select name="grade_options" onchange="checkUpdate(<%= rowN%>)">
        <option value="Letter" <%= (grade_options.equals("Letter")) ? "selected" : "" %>>Letter only</option>
        <option value="S/U" <%= (grade_options.equals("S/U")) ? "selected" : "" %>>S/U only</option>
        <option value="Letter/S/U" <%= (grade_options.equals("Letter/S/U")) ? "selected" : "" %>>Letter or S/U</option>
      </select>
    </td>
    <td>
      <select name="course_level" onchange="checkUpdate(<%= rowN%>)">
        <option value="lower" <%= (course_level.equals("lower")) ? "selected" : "" %>>Lower</option>
        <option value="upper" <%= (course_level.equals("upper")) ? "selected" : "" %>>Upper</option>
        <option value="graduate" <%= (course_level.equals("graduate")) ? "selected" : "" %>>Graduate</option>
      </select>
    </td>
    <td><input type="text" name="unit_low" value="<%= unit_low %>" size="2"></td>
    <td><input type="text" name="unit_high" value="<%= unit_high %>" size="2"></td>
    
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update"></td>
  </form>
  
  <form action="courses.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="course_id" value="<%= course_id %>">
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
    rs_dept.close();
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