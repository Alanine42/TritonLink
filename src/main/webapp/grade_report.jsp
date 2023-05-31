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
<form action="grade_report.jsp" method="post">         
    <select name="ssn" id="ssn_insert">
      <option value="">-- select student by ssn--</option>
      <% for (String ssn : ssns) { %>
        <option value="<%= ssn %>"><%= ssn %></option>
      <% } %>
    </select>
  <input type="submit" value="Get grade report of this student">
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
    PreparedStatement pstmt;
        // get all the past classes by this student
    pstmt = conn.prepareStatement("select ct.section_id, c.course_id, c.quarter, c.title, c.faculty_name, c.available_seats, c.total_seats, ct.unit, ct.grade from classes_taken ct, classes c where ct.student_id=? and ct.section_id=c.section_id order by quarter");
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

      int unit = rs.getInt("unit");
      String grade = rs.getString("grade");
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
    <td><%= grade %></td>
  </tr>

<%
    }
%>
</table>

<br>

<%-- Get average GPA of each quarter --%>

<table>
  <tr>
    <th>Average GPA</th>
    <th>Quarter</th>
  </tr>

<%
    PreparedStatement pstmt2;
        // get all the past classes by this student
    pstmt2 = conn.prepareStatement("select avg(number_grade) as avg_grade, quarter from classes_taken ct join grade_conversion gc on ct.grade = gc.letter_grade join classes c on c.section_id = ct.section_id where student_id = ? and ct.grade <> 'IN' group by quarter");
    pstmt2.setString(1, _student_id);
    ResultSet rs2 = pstmt2.executeQuery();

    while (rs2.next()) {
      String avg_grade = rs2.getString("avg_grade");
      String quarter = rs2.getString("quarter");
%>
  <tr>
    <td><%= avg_grade %></td>
    <td><%= quarter %></td>
<%
    }
%>


<%-- Cumulative GPA --%>
<%
    PreparedStatement pstmt3;
    pstmt3 = conn.prepareStatement("select avg(number_grade) as cum_avg from classes_taken ct join grade_conversion gc on ct.grade = gc.letter_grade join classes c on c.section_id = ct.section_id where student_id = ? and ct.grade <> 'IN'");
    pstmt3.setString(1, _student_id);
    ResultSet rs3 = pstmt3.executeQuery();
    if (rs3.next()) {
      String cum_avg = rs3.getString("cum_avg");

%>

  <tr><br></tr>
  <br>
  <tr>
    <td><%= cum_avg %></td>
    <td><b>Cumulative GPA</b></td>
  </tr>

<%
    }
%>

<%-- <br><code>Close connection code</code> --%>
<%
    rs.close();
    pstmt.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e);
  }
  catch (Exception e) {
    out.println(e);
  }

%>