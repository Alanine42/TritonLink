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


<%
    // Fetch SSNs of all students enrolled in the current quarter (Spring 2018)
    Statement stmt_ssn = conn.createStatement();
    ResultSet rs_ssn = stmt_ssn.executeQuery("select ssn from students order by ssn");
    ArrayList<String> ssns = new ArrayList<String>();
    while (rs_ssn.next()) {
        ssns.add(rs_ssn.getString("ssn"));
    }
%>
<%-- Select one studnet by their SSN --%>
<form action="student_taking.jsp" method="post">         
    <select name="ssn" id="ssn_insert">
      <option value="">-- select student --</option>
      <% for (String ssn : ssns) { %>
        <option value="<%= ssn %>"><%= ssn %></option>
      <% } %>
    </select>
  <input type="submit" value="Get classes currently taking by this student">
</form>


<%
    // For the selected student, display their SSN, FIRSTNAME, MIDDLENAME and LASTNAME attributes
    String _ssn = request.getParameter("ssn");
    PreparedStatement pstmt_student = conn.prepareStatement("select fname, mname, lname, student_id from students where ssn=?");
    pstmt_student.setString(1, _ssn);
    ResultSet rs_student = pstmt_student.executeQuery();

    String _fname = "";
    String _mname = "";
    String _lname = "";
    String _student_id = "";
    if (rs_student.next()) {
        _fname = rs_student.getString("fname");
        _mname = rs_student.getString("mname");
        _lname = rs_student.getString("lname");
        _student_id = rs_student.getString("student_id");
    }

%>

<table>
  <tr>
    <th>SSN</th>
    <th>First Name</th>
    <th>Middle Name</th>
    <th>Last Name</th>
  </tr>
  <tr>
    <td><%= _ssn %></td>
    <td><%= _fname %></td>
    <td><%= _mname %></td>
    <td><%= _lname %></td>
  </tr>
</table>


<%-- For the selected student, display the classes they are currently taking in the current quarter (Spring 2018) --%>
<h3>Classes currently taking by this student</h3> 
<table>
  <tr>
    <th>Section ID</th>
    <th>Course ID</th>
    <th>Quarter</th>
    <th>Title</th>
    <th>Faculty Name</th>
    <th>Available Seats</th>
    <th>Total Seats</th>
    <th>Unit</th>
    <th>Grade</th>
  </tr>

<%
    PreparedStatement pstmt = conn.prepareStatement("select cs.*, ce.unit, ce.grading_option from classes cs, course_enrollment ce where ce.student_id = ? and ce.section_id = cs.section_id and cs.quarter = 'Spring 2018' and enrollment_status = 'enroll'");
    pstmt.setString(1, _student_id);
    ResultSet rs = pstmt.executeQuery();
    while (rs.next()) {
      String section_id = rs.getString("section_id");
      String course_id = rs.getString("course_id");
      String quarter = rs.getString("quarter");
      String title = rs.getString("title");
      String faculty_name = rs.getString("faculty_name");
      String available_seats = rs.getString("available_seats");
      String total_seats = rs.getString("total_seats");

      String unit = rs.getString("unit");
      String grading_option = rs.getString("grading_option");
%>

  <tr>
    <td><%= section_id %></td>
    <td><%= course_id %></td>
    <td><%= quarter %></td>
    <td><%= title %></td>
    <td><%= faculty_name %></td>
    <td><%= available_seats %></td>
    <td><%= total_seats %></td>
    <td><%= unit %></td>
    <td><%= grading_option %></td>
  </tr>


<%
    }
%>

</table>

<%-- <br><code>Close connection code</code> --%>
<%
    //rs.close();
    //stmt.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e);
  }
  catch (Exception e) {
    out.println(e);
  }

%>