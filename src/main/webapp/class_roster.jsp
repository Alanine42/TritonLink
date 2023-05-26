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

<%-- Select class by their title --%>
<tr>
    <form action="class_roster.jsp" method="post">         
        <td><p>input title: </p><input type="text" name="title", size="12"></td>
        <td><p>input quarter and year: </p><input type="text" name="quarter", size="12"></td><br>
        <td><input type="submit" value="Get class roster"></td>
    </form>
</tr>

<%
    // For the selected title, display their course_id, quarter, and year
    String _title = request.getParameter("title");
    String _quarter = request.getParameter("quarter");
    PreparedStatement pstmt_class = conn.prepareStatement("select distinct course_id from classes where title=? and quarter=?");
    pstmt_class.setString(1, _title);
    pstmt_class.setString(2, _quarter);
    ResultSet rs_class = pstmt_class.executeQuery();

    String _course_id = "";

    if (rs_class.next()) {
        _course_id = rs_class.getString("course_id");
    }

%>

<table>
  <tr>
    <th>Course ID</th>
    <th>Quarter</th>
  </tr>
  <tr>
    <td><%= _course_id %></td>
    <td><%= _quarter %></td>
  </tr>
</table>

<table>
  <tr>
    <th>Student ID</th>
    <th>First Name</th>
    <th>Middle Name</th>
    <th>Last Name</th>
    <th>SSN</th>
    <th>Residency</th>
    <th>Unit</th>
    <th><%= _quarter.equals("Spring 2018") ? "Grading Option" : "Grade"%></th>
  </tr>

<%
    PreparedStatement pstmt;
    if (_quarter.equals("Spring 2018")) {
        // current quarter - use course_enrollment table
        pstmt = conn.prepareStatement("select distinct s.*, ce.unit, ce.grading_option from students s, course_enrollment ce where ce.section_id in (select section_id from classes where title=? and quarter=?) and s.student_id=ce.student_id");
    }
    else {
        pstmt = conn.prepareStatement("select distinct students.*, unit, grade from classes_taken join students on classes_taken.student_id = students.student_id where section_id in (select section_id from classes where title = ? and quarter = ?);");
    }
    pstmt.setString(1, _title);
    pstmt.setString(2, _quarter);
    ResultSet rs = pstmt.executeQuery();
    while (rs.next()) {
      String student_id = rs.getString("student_id");
      String fname = rs.getString("fname");
      String mname = rs.getString("mname");
      String lname = rs.getString("lname");
      String ssn = rs.getString("ssn");
      String residency = rs.getString("residency");

      String unit = rs.getString("unit");
      String grading_option = (_quarter.equals("Spring 2018")) ? rs.getString("grading_option"): rs.getString("grade");
%>

  <tr>
    <td><%= student_id %></td>
    <td><%= fname %></td>
    <td><%= mname %></td>
    <td><%= lname %></td>
    <td><%= ssn %></td>
    <td><%= residency %></td>
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