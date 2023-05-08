<%@ page language="java" import="java.sql.*"  %>

<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5433/tritonlinkDB", "postgres", "409621a");
    out.println("Connected to Postgres!");
// [!] un/comment the line below to get syntax highlighting for below html codes. 
      //}
%>  

<%-- <br><code> Insertion, Update, Delete </code> --%>
<%
    String action = request.getParameter("action");

    // Insertion Code
    if (action != null && action.equals("insert")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "insert into students values (?, ?, ?, ?, ?, ?)");
      String student_id = request.getParameter("student_id");
      if (student_id == null || student_id.length() == 0) {
        throw new Exception("Student ID cannot be empty");
      }

      pstmt.setString(1, request.getParameter("student_id"));
      pstmt.setString(2, request.getParameter("fname"));
      // [?] How to insert optional value (mname)?
      pstmt.setString(3, request.getParameter("mname"));
      pstmt.setString(4, request.getParameter("lname"));
      pstmt.setString(5, request.getParameter("ssn"));
      pstmt.setString(6, request.getParameter("residency"));
      pstmt.executeUpdate();

      conn.commit();
      conn.setAutoCommit(true);
    }

    // Update Code
    if (action != null && action.equals("update")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "update students set fname=?, mname=?, lname=?, ssn=?, residency=? where student_id=?");
      pstmt.setString(1, request.getParameter("fname"));
      pstmt.setString(2, request.getParameter("mname"));
      pstmt.setString(3, request.getParameter("lname"));
      pstmt.setString(4, request.getParameter("ssn"));
      pstmt.setString(5, request.getParameter("residency"));
      pstmt.setString(6, request.getParameter("student_id"));
      int rowCount = pstmt.executeUpdate();   // returns # of rows effected

      conn.commit();
      conn.setAutoCommit(true);
    }

    // Delete Code
    if (action != null && action.equals("delete")) {
      conn.setAutoCommit(false);

      PreparedStatement pstmt = conn.prepareStatement(
          "delete from students where student_id=?");

      pstmt.setString(1, request.getParameter("student_id"));

      int rowCount = pstmt.executeUpdate();   // returns # of rows effected

      conn.commit();
      conn.setAutoCommit(true);
    }

    response.sendRedirect("index.jsp?type=students");  // avoid refresh = re-insertion

%>

<%-- <br><code>Update code</code> --%>
<%



%>

<%-- <br><code>Statement code</code> --%>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from students order by student_id");
%>

<%-- <br><code>Presentation code</code> --%>
<table>
  <tr>
    <th>Student ID</th>
    <th>First Name</th>
    <th style="color: gray;">Middle Name</th>
    <th>Last Name</th>
    <th>SSN</th>
    <th>Residency</th>
  </tr>

  <tr>
    <form action="students.jsp" method="get">         
      <input type="hidden" name="action" value="insert">
      <td><input type="text" name="student_id" size="12"></td>
      <td><input type="text" name="fname" size="12"></td>
      <td><input type="text" name="mname" size="12"></td>
      <td><input type="text" name="lname" size="12"></td>
      <td><input type="text" name="ssn" size="12"></td>
      <td><select name="residency" >
          <option value="CA resident">CA resident</option>
          <option value="Non-CA US">Non-CA US</option>
          <option value="Foreign">Foreign</option>
          </select>
      </td>
      <td><input type="submit" value="Insert"></td>
    </form>
  </tr>

<% 
  while (rs.next()) { 
    String student_id = rs.getString("student_id");
    String fname = rs.getString("fname");
    String mname = rs.getString("mname");
    String lname = rs.getString("lname");
    String ssn = rs.getString("ssn");
    String residency = rs.getString("residency");
%>

  <%-- New: presenting the rows with edit/delete --%>
  <tr>
    <form action="students.jsp" method="get">         
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="student_id" value="<%= student_id %>">
      <td><input type="text" name="student_id" size="12" value="<%= student_id %>" readonly></td>
      <td><input type="text" name="fname" size="12" value="<%= fname %>"></td>
      <td><input type="text" name="mname" size="12" value="<%= mname %>"></td>
      <td><input type="text" name="lname" size="12" value="<%= lname %>"></td>
      <td><input type="text" name="ssn" size="12" value="<%= ssn %>"></td>
      <td><select name="residency" >
          <option value="CA resident" <%= residency.equals("CA resident") ? "selected" : "" %>>CA resident</option>
          <option value="Non-CA US" <%= residency.equals("Non-CA US") ? "selected" : "" %>>Non-CA US</option>
          <option value="Foreign" <%= residency.equals("Foreign") ? "selected" : "" %>>Foreign</option>
          </select>
      </td>
      <td><input type="submit" value="Update"></td>
    </form>
    
    <form action="students.jsp" method="get">         
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="student_id" value="<%= student_id %>">
      <td><input type="submit" value="Delete"></td>
    </form>
  </tr>

<%-- Old: just presenting the rows (No edit/delete) --%>
  <%-- <tr>
    <td><%= student_id %></td>
    <td><%= fname %></td>
    <td><%= mname %></td>
    <td><%= lname %></td>
    <td><%= ssn %></td>
    <td><%= residency %></td>
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
  }
  catch (Exception e) {
    out.println(e.getMessage());
  }

%>