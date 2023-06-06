<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList"  %>


<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/postgres", "postgres", "postgres");
%>  


<%-- <br><code> Insertion, Update, Delete </code> --%>
<%
    // Get all the parameters from the form, enforce the non-null's
    String _course_id = request.getParameter("course_id");
    String _req_id = request.getParameter("req_id");

    String action = request.getParameter("action"); 

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into fulfillment values (?, ?)");
      
      pstmt.setString(1, _course_id);
      pstmt.setString(2, _req_id);

      pstmt.executeUpdate();
      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from fulfillment where course_id=? and req_id=?");

      pstmt.setString(1, _course_id);
      pstmt.setString(2, _req_id);

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected
      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=fulfillment");  // avoid refresh = re-insertion

%>

<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from fulfillment order by course_id");
    
    Statement stmt_courses = conn.createStatement();
    ResultSet rs_courses = stmt_courses.executeQuery("select course_id from courses order by course_id");
    ArrayList<String> courses = new ArrayList<String>();
    courses.add("");  // empty option for the select tag
    while (rs_courses.next()) {
      courses.add(rs_courses.getString("course_id"));
    }

%>

<script>
function checkInsert() {
  let courseIdInsert = document.getElementById("course_id_insert");
  let reqIdInsert = document.getElementById("req_id_insert");
  var insertButton = document.getElementById("insert_button");
  
  if (courseIdInsert.value == "" || reqIdInsert.value == "") {
    insertButton.disabled = true;
    //insertButton.style.opacity = "0.5"; // dim the button
  } else {
    insertButton.disabled = false;
    //insertButton.style.opacity = "1"; // reset the button opacity
  }
}
</script>


<table>
  <tr>
    <th>Course ID</th>
    <th>Req ID</th>
  </tr>

  <tr>
    <form action="courses.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td>
        <select name="course_id" id="course_id_insert" onchange="checkInsert()">
          <% for (String course : courses) { %>
            <option value="<%= course %>"><%= course %></option>
          <% } %>
        </select>
      </td>
      <td><input type="text" name="req_id" id="req_id_insert" size="16"></td>
      
      <td><input type="submit" value="Insert" id="insert_button" disabled></td>
    </form>
  </tr>


<% 
  while (rs.next()) { 
    int rowN = rs.getRow();  // for JS checker to identify each row in the table
    String course_id = rs.getString("course_id");
    String req_id = rs.getString("req_id"); 
%>

<tr>
  <td><%= course_id %></td>
  <td><%= req_id %></td>
  
  <form action="fulfillment.jsp" method="get">         
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="course_id" value="<%= course_id %>">
    <input type="hidden" name="req_id" value="<%= req_id %>">
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
    rs_courses.close();
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