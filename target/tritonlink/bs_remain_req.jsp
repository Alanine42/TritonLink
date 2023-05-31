<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList" %>


<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/postgres", "postgres", "postgres");
    // out.println("Connected to Postgres!");
%>  

<%
    // Fetch SSNs of all undergraduates
    Statement stmt_ssn = conn.createStatement();
    ResultSet rs_ssn = stmt_ssn.executeQuery("select ssn from students where student_id in (select student_id from undergraduates) order by ssn");
    ArrayList<String> ssns = new ArrayList<String>();
    while (rs_ssn.next()) {
        ssns.add(rs_ssn.getString("ssn"));
    }

    // Fetch all the degrees
    Statement stmt_degree = conn.createStatement();
    ResultSet rs_degree = stmt_degree.executeQuery("select distinct degree from bs_requirement order by degree");
    ArrayList<String> degrees = new ArrayList<String>();
    while (rs_degree.next()) {
        degrees.add(rs_degree.getString("degree"));
    }
%>
<%-- Select one studnet by their SSN --%>
<form action="bs_remain_req.jsp" method="post">         
    <select name="ssn" id="ssn_insert">
      <option value="">-- select undergraduate student --</option>
      <% for (String ssn : ssns) { %>
        <option value="<%= ssn %>"><%= ssn %></option>
      <% } %>
    </select>

    <select name="degree" id="degree_insert">
      <option value="">-- select degree --</option>
      <% for (String degree : degrees) { %>
        <option value="<%= degree %>"><%= degree %></option>
      <% } %>
    </select>
  <input type="submit" value="Get all the info">
</form>


<%
    // For the selected undergraduate, display their SSN, FIRSTNAME, MIDDLENAME and LASTNAME attributes
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
    <th>Type</th>
  </tr>
<%
    // For the selected degree, display their req_id, degree, course_type and min_units attributes
    String _degree = request.getParameter("degree");
    PreparedStatement pstmt_type = conn.prepareStatement("select req_id, degree, course_type, min_units from bs_requirement where degree=?");
    pstmt_type.setString(1, _degree);
    ResultSet rs_type = pstmt_type.executeQuery();

    String _type = "";
    int tot_unit = 0;
    ArrayList<String> req_ids = new ArrayList<String>();
    ArrayList<Integer> rem_units = new ArrayList<Integer>();
    ArrayList<String> types = new ArrayList<String>();
    while (rs_type.next()) {
        req_ids.add(rs_type.getString("req_id"));
        rem_units.add(rs_type.getInt("min_units"));
        types.add(rs_type.getString("course_type"));
        _type = rs_type.getString("course_type");
        tot_unit += rs_type.getInt("min_units");
    
%>

  <tr>
    <td><%= _type %></td>
  </tr>
<%
    }
%>

</table>

<%

    PreparedStatement pstmt_req = conn.prepareStatement("select co.req_ids, ct.unit from courses co, classes cl, classes_taken ct where ct.student_id = ? and ct.section_id = cl.section_id and cl.course_id = co.course_id");
    pstmt_req.setString(1, _student_id);
    ResultSet rs_req = pstmt_req.executeQuery();

    String _req_ids = "";
    int _unit = 0;
    while (rs_req.next()) {

        // req_id is the id of a course_tpye(core CS26 etc.) while _req_ids are the ids a class fulfills 
        // (CSE 132 fulfill core CS26 and elective CS26etc)
        _req_ids = rs_req.getString("req_ids");
        _unit = rs_req.getInt("unit");
        for(int i = 0; i < req_ids.size(); i++) {
            // whether this class fulfill a requirement
            String[] _req_ids_arr = _req_ids.split(",");
            for(String id : _req_ids_arr) {
                if(id.equals(req_ids.get(i))) {
                    rem_units.set(i, rem_units.get(i) - _unit);
                    tot_unit -= _unit;
                }
            }
        }
    }

%>

<br><p>Remaining unit is "<%= tot_unit %>"</p><br>

<div>
  <% for(int i = 0; i < req_ids.size(); i++){ %>
  <p>
    <%= types.get(i) %> has <%= rem_units.get(i) %> units remaining,
    <% if(rem_units.get(i) <= 0) { %>
      <span style="color: green">Requirement Fulfilled</span>
    <% } %>
  </p>
  <% } %>
  <br>
</div>

<%-- <br><code>Close connection code</code> --%>
<%
    rs_req.close();
    rs_student.close();
    rs_degree.close();
    rs_type.close();
    stmt_ssn.close();
    pstmt_student.close();
    stmt_degree.close();
    pstmt_type.close();
    pstmt_req.close();
    conn.close();
  } 
  catch (SQLException e) {
    out.println(e);
  }
  catch (Exception e) {
    out.println(e);
  }

%>