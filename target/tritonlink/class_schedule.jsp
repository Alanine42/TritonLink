<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.*" %>


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
    ResultSet rs_ssn = stmt_ssn.executeQuery("select ssn from students where student_id in (select distinct student_id from course_enrollment) order by ssn");
    ArrayList<String> ssns = new ArrayList<String>();
    while (rs_ssn.next()) {
        ssns.add(rs_ssn.getString("ssn"));
    }
%>
<%-- Select one studnet by their SSN --%>
<form action="class_schedule.jsp" method="post">         
    <select name="ssn" id="ssn_insert">
      <option value="">-- select student --</option>
      <% for (String ssn : ssns) { %>
        <option value="<%= ssn %>"><%= ssn %></option>
      <% } %>
    </select>
  <input type="submit" value="Get classes currently taking by this student and Other conflicting classes">
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


<%  
  Statement stmt = conn.createStatement();

  // stmt.executeUpdate("drop table if exists taking CASCADE");

  String sql = "create table taking as select c.title, c.course_id, m.day, m.start_time, m.end_time, m.section_id from course_enrollment ce join meetings m on ce.section_id = m.section_id join classes c on c.section_id = ce.section_id where student_id =? and c.quarter = 'Spring 2018'";
  PreparedStatement pstmt = conn.prepareStatement(sql);
  pstmt.setString(1, _student_id);
  pstmt.executeUpdate();

  stmt.executeUpdate("create or replace view other as select c.title, c.course_id, m.day, m.start_time, m.end_time from classes c join meetings m on c.section_id = m.section_id where quarter = 'Spring 2018' and c.section_id not in (select t.section_id from taking t)");

  ResultSet rs_conflicting = stmt.executeQuery("select distinct t.course_id, t.title, o.course_id as conflict_course_id, o.title as conflict_title from taking t join other o on t.day = o.day and t.start_time <= o.end_time and o.start_time <= t.end_time order by o.course_id, t.course_id");  


%>

<h2>Your current classes | <span style="color: red;">Other Conflicting classes you cannot take</span></h2>
<table>
  <tr>
    <th>Course ID</th>
    <th>Course Title</th>
    <th><span style="color: red;">Conflict Course ID</span></th>
    <th><span style="color: red;">Conflict Course Title</span></th>
  </tr>
  <% while (rs_conflicting.next()) { %>
  <tr>
    <td><%= rs_conflicting.getString("course_id") %></td>
    <td><%= rs_conflicting.getString("title") %></td>
    <td><%= rs_conflicting.getString("conflict_course_id") %></td>
    <td><%= rs_conflicting.getString("conflict_title") %></td>
  </tr>
  <% } %>



<%-- <br><code>Close connection code</code> --%>
<%
    rs_conflicting.close();
    stmt_ssn.close();
    pstmt_student.close();
    pstmt.close();
    stmt.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e);
  }
  catch (Exception e) {
    out.println(e);
  }

/*
todo: 
constraint -- course enrollment's section_id must be offered in the current quarter (Spring 2018)

*/

%>