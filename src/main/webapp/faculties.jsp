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
    String _faculty_name = request.getParameter("faculty_name");
    String _title = request.getParameter("title");
    String department1 = request.getParameter("department1");
    String department2 = request.getParameter("department2");
    String department3 = request.getParameter("department3");
    String[] _departments = {department1, department2, department3};

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into faculties values (?, ?, ?)");
      
      pstmt.setString(1, _faculty_name);
      pstmt.setString(2, _title);
      pstmt.setArray(3, conn.createArrayOf("text", _departments));   // "text" ? 
  
      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update faculties set title=?, departments=? where faculty_name=?");
      
      pstmt.setString(1, _title); 
      pstmt.setArray(2, conn.createArrayOf("text", _departments));   // "text" ?
      pstmt.setString(3, _faculty_name);
      
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from faculties where faculty_name=?");

      pstmt.setString(1, _faculty_name);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=faculties");  // avoid refresh = re-insertion

%>


<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from faculties order by faculty_name");
    
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
  var facultyNameInsert = document.getElementById("faculty_name_insert");
  var departmentInsert1 = document.getElementById("department_insert1");
  var insertButton = document.getElementById("insert_button");
  
  if (facultyNameInsert.value == "" || departmentInsert1 == "") {
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
    <th>Faculty Name</th>
    <th>Title</th>
    <th>Departments</th>
  </tr>

  <tr>
    <form action="faculties.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="faculty_name" size="12" id="faculty_name_insert" onkeyup="checkInsert()"></td>
      <td>
        <select name="title" id="title_insert">
          <option value="Professor">Professor</option>
          <option value="Assistant Professor">Assistant Professor</option>
          <option value="Associate Professor">Associate Professor</option>
          <option value="Lecturer">Lecturer</option>
        </select>
      </td>
      <td>
        <select name="department1" id="department_insert1" onchange="checkInsert()">

          <% for (String dept : depts) { %>
            <option value="<%= dept %>"><%= dept %></option>
          <% } %>
        </select>
      </td>
      <td>
        <select name="department2">

          <% for (String dept : depts) { %>
            <option value="<%= dept %>"><%= dept %></option>
          <% } %>
        </select>
      </td>
      <td>
        <select name="department3">

          <% for (String dept : depts) { %>
            <option value="<%= dept %>"><%= dept %></option>
          <% } %>
        </select>
      </td>

      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String faculty_name = rs.getString("faculty_name");
    String title = rs.getString("title");
    String[] departments = (String[]) rs.getArray("departments").getArray();
    
%>


<tr>
  <form action="faculties.jsp" method="get">         
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="faculty_name" value="<%= faculty_name %>">
    <td><input type="text" class="<%= rowN%>" name="faculty_name" size="12" value="<%= faculty_name %>" readonly ></td>
    <td>
      <select name="title" class="<%= rowN%>" >
        <option value="Professor" <%= title.equals("Professor") ? "selected" : "" %>>Professor</option>
        <option value="Assistant Professor" <%= title.equals("Assistant Professor") ? "selected" : "" %>>Assistant Professor</option>
        <option value="Associate Professor" <%= title.equals("Associate Professor") ? "selected" : "" %>>Associate Professor</option>
        <option value="Lecturer" <%= title.equals("Lecturer") ? "selected" : "" %>>Lecturer</option>
      </select>
    </td>
    <td>
      <select name="department1" >
        <% for (String dept : depts) { %>
          <option value="<%= dept %>" <%= (departments[0] != null && departments[0].equals(dept)) ? "selected" : "" %>><%= dept %></option>
        <% } %>
      </select>
    </td>
    <td>
      <select name="department2">
        <% for (String dept : depts) { %>
          <option value="<%= dept %>" <%= (departments[1] != null && departments[1].equals(dept)) ? "selected" : "" %>><%= dept %></option>
        <% } %>
      </select>
    </td>
    <td>
      <select name="department3">
        <% for (String dept : depts) { %>
          <option value="<%= dept %>" <%= (departments[2] != null && departments[2].equals(dept)) ? "selected" : "" %>><%= dept %></option>
        <% } %>
      </select>
    </td>
    <td><input type="submit" id="update_button_<%= rowN%>" value="Update"></td>
  </form>
  
  <form action="faculties.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="faculty_name" value="<%= faculty_name %>">
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