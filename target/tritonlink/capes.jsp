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
    // Fetch all course_ids
    Statement stmt_course = conn.createStatement();
    ResultSet rs_course = stmt_course.executeQuery("select course_id from courses order by course_id");
    ArrayList<String> courses = new ArrayList<String>();
    while (rs_course.next()) {
        courses.add(rs_course.getString("course_id"));
    }

    // Fetch all professors
    Statement stmt_prof = conn.createStatement();
    ResultSet rs_prof = stmt_prof.executeQuery("select faculty_name from faculties order by faculty_name");
    ArrayList<String> profs = new ArrayList<String>();
    while (rs_prof.next()) {
        profs.add(rs_prof.getString("faculty_name"));
    }
    profs.add("all");

    // Fetch all quarters
    Statement stmt_quarter = conn.createStatement();
    ResultSet rs_quarter = stmt_quarter.executeQuery("select distinct quarter from classes order by quarter");
    ArrayList<String> quarters = new ArrayList<String>();
    while (rs_quarter.next()) {
        quarters.add(rs_quarter.getString("quarter"));
    }
    quarters.add("all");
%>

<%-- Select one studnet by their SSN --%>
<form action="capes.jsp" method="post">         
    <select name="course" id="course_insert">
      <option value="">-- select course --</option>
      <% for (String course : courses) { %>
        <option value="<%= course %>"><%= course %></option>
      <% } %>
    </select>

    <select name="prof" id="prof_insert">
      <option value="all">-- select professor --</option>
      <% for (String prof : profs) { %>
        <option value="<%= prof %>"><%= prof %></option>
      <% } %>
    </select>

    <select name="quarter" id="quarter_insert">
      <option value="all">-- select quarter --</option>
      <% for (String quarter : quarters) { %>
        <option value="<%= quarter %>"><%= quarter %></option>
      <% } %>
    </select>

  <input type="submit" value="Get the capes">
</form>

<%

    String course = request.getParameter("course");
    String prof = request.getParameter("prof");
    String quarter = request.getParameter("quarter");

    if (quarter.equals("all")) {
      if (prof.equals("all")){
        // No. 4
      }
      else {
        // No. 3 and No. 5
      }
    }
    else{
      // No. 2
        Statement stmt = conn.createStatement();
        stmt.executeQuery("drop table if exists CPQG CASCADE");

        PreparedStatement pstmt = conn.prepareStatement("create table if not exists CPQG as (select c.course_id, c.quarter, c.faculty_name, ct.grade from classes c join calsses_taken on c.section_id = ct.section_id where c.course_id = ? and c.faculty_name = ? and c.quarter = ?)");
        pstmt.setString(1, course);
        pstmt.setString(2, prof);
        pstmt.setString(3, quarter);
        pstmt.executeUpdate();
        
        String grade = "";
        int grade_count = 0;
        PreparedStatement pstmt2 = conn.prepareStatement("select grade, count(*) as grade_count from CPQG group by grade");
        ResultSet rs2 = pstmt2.executeQuery();
        while(rs2.next()){
          grade = rs2.getString("grade");
          grade_count = rs2.getInt("grade_count");
%>
          <p><%= grade %>: <%= grade_count %></p><br>
<%
        }
%>


<%
    }

%>





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