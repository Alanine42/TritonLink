<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.lang.Double" %>


<%-- <code>Open connection code</code> --%>
<% 
  try {
    Class.forName("org.postgresql.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/postgres", "postgres", "postgres");
    // out.println("Connected to Postgres!");
%>  

<%
    // Fetch SSNs of all masters
    Statement stmt_ssn = conn.createStatement();
    ResultSet rs_ssn = stmt_ssn.executeQuery("select ssn from students where student_id in (select student_id from masters) order by ssn");
    ArrayList<String> ssns = new ArrayList<String>();
    while (rs_ssn.next()) {
        ssns.add(rs_ssn.getString("ssn"));
    }

    // Fetch all concentrations
    Statement stmt_degree = conn.createStatement();
    ResultSet rs_degree = stmt_degree.executeQuery("select distinct degree from ms_requirement order by degree");
    ArrayList<String> degrees = new ArrayList<String>();
    while (rs_degree.next()) {
        degrees.add(rs_degree.getString("degree"));
    }
%>

<%-- Select one studnet by their SSN --%>
<form action="ms_remain_req.jsp" method="post">         
    <select name="ssn" id="ssn_insert">
      <option value="">-- master student SSN --</option>
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

    <input type="number" step="0.1" name="min_gpa" placeholder="min_gpa">
  <input type="submit" value="Get the reamainning graduate requirement of this master">
</form>


<%
    // For the selected master, display their SSN, FIRSTNAME, MIDDLENAME and LASTNAME attributes
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
    <th>Concentration</th>
    <th>Minimum Units</th>
  </tr>

<%
    // For the selected concentration, display their min_units attributes
    String _degree = request.getParameter("degree");
    PreparedStatement pstmt_type = conn.prepareStatement("select concentration, min_units from ms_requirement where degree=?");
    pstmt_type.setString(1, _degree);
    ResultSet rs_type = pstmt_type.executeQuery();

    String concentration = "";
    int _min_unit = 0;
    int total_unit = 0;

    ArrayList<String> concentrations = new ArrayList<String>();
    ArrayList<Integer> rem_units = new ArrayList<Integer>();

    while (rs_type.next()) {
        concentration = rs_type.getString("concentration");
        _min_unit = rs_type.getInt("min_units");
        total_unit += _min_unit;
        concentrations.add(concentration);
        rem_units.add(_min_unit);
    
%>
  <tr>
    <td><%= concentration %></td>
    <td><%= _min_unit %></td>
  </tr>

  <% } %>

</table>

<%
    Double _min_gpa = Double.parseDouble(request.getParameter("min_gpa"));
    PreparedStatement pstmt_req = conn.prepareStatement("select req_id, unit from classes_taken ct join classes c on ct.section_id = c.section_id join fulfillment f on f.course_id = c.course_id join grade_conversion g on grade = g.letter_grade where ct.student_id = ? and g.number_grade > ?");
    pstmt_req.setString(1, _student_id);
    pstmt_req.setDouble(2, _min_gpa);
    ResultSet rs_req = pstmt_req.executeQuery();

    String req_id = "";
    int unit = 0;
    while (rs_req.next()) {
      req_id = rs_req.getString("req_id");
      unit = rs_req.getInt("unit");


        // req_id is the id of a course_tpye(core CS26 etc.) while _req_ids are the ids a class fulfills 
        // (CSE 132 fulfill core CS26 and elective CS26etc)
        req_id = rs_req.getString("req_ids");
        _unit = rs_req.getInt("unit");
        for(int i = 0; i < concentrations.size(); i++) {
            // whether this class fulfill a requirement
            String[] req_id_arr = req_id.split(",");
            for(String id : req_id_arr) {
                if(id.equals(concentrations.get(i))) {
                    rem_units.set(i, rem_units.get(i) - _unit);
                    total_unit -= _unit;
                }
            }
        }
    }

%>

<br><p>remainning unit is "<%= total_unit %>"</p><br>

<div>
  <% for(int i = 0; i < concentrations.size(); i++){ %>
  <p>
    <%= concentrations.get(i) %> has <%= rem_units.get(i) %> units remaining,
    <% if(rem_units.get(i) <= 0) { %>
      <span style="color: green">Requirement Fulfilled</span>
    <% } %>
  </p>
  <% } %>
  <br>
</div>

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


/*
todo: Make table (course_id, concentration)

  Easier to group by concentration and calculate student's:
  - average grade for each concentration
  - courses not yet taken for each concentration
  
*/
%>
