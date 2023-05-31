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


<%
  boolean hasConflict(ArrayList<ArrayList<String>> day, String start, String end) {
    for (ArrayList<String> time : day) {
      String myStart = time.get(0);
      String myEnd = time.get(1);
      if (myStart.length() == 4) {
          myStart= "0" + myStart;
      }

      if (myEnd.length() == 4) {
          myEnd = "0" + myEnd;
      }

      if (start.length() == 4) {
          start = "0" + start;
      }

      if (end.length() == 4) {
          end = "0" + end;
      }

      if ((end.compareTo(myStart) > 0) && (start.compareTo(myEnd) < 0)) {
        return true;
      }
    }
    return false;
  }
%>

<%

    // Create a view for this student's current classes' meetings
    ArrayList<ArrayList<String>> monday = new ArrayList<ArrayList<String>>();   // [[start, end], [start, end], ...]
    ArrayList<ArrayList<String>> tuesday = new ArrayList<ArrayList<String>>();
    ArrayList<ArrayList<String>> wednesday = new ArrayList<ArrayList<String>>();
    ArrayList<ArrayList<String>> thursday = new ArrayList<ArrayList<String>>();
    ArrayList<ArrayList<String>> friday = new ArrayList<ArrayList<String>>();

    ArrayList<ArrayList<ArrayList<String>>> weekdays = new ArrayList<ArrayList<ArrayList<String>>>();
    days.add(monday);
    days.add(tuesday);
    days.add(wednesday);
    days.add(thursday);
    days.add(friday);

    PreparedStatement pstmt = conn.prepareStatement("create or replace view taking as select m.section_id, m.days, m.start_time, m.end_time from course_enrollment ce join meetings m on ce.section_id = m.section_id where student_id = ?");
    pstmt.setString(1, _student_id);

    String days = "";
    
    Statement stmt_taking = conn.createStatement();
    ResultSet rs_taking = stmt_taking.executeQuery("select section_id, days, start_time, end_time from taking order by section_id");
    while (rs_rs_taking.next()) {
        ArrayList<String> time = new ArrayList<String>();
        days = rs_taking.getString("days");

        time.add(rs_taking.getString("start_time"));
        time.add(rs_taking.getString("end_time"));
        if (days.contains("M")) {
            monday.add(time);
        }
        else if (days.contains("Tu")) {
            tuesday.add(time);
        }
        else if (days.contains("W")) {
            wednesday.add(time);
        }
        else if (days.contains("Th")) {
            thursday.add(time);
        }
        else if (days.contains("F")) {
            friday.add(time);
        }

    }

    // sort each day by start time
    for (ArrayList<ArrayList<String>> day : weekdays) {
      Collections.sort(day, new Comparator<ArrayList<String>>() {
          @Override
          public int compare(ArrayList<String> a, ArrayList<String> b) {
              if (a.get(0).length() == 4) {
                  a.set(0, "0" + a.get(0));
              }
              if (b.get(0).length() == 4) {
                  b.set(0, "0" + b.get(0));
              }
              return a.get(0).compareTo(b.get(0));
          }
      });
    }  
  

    boolean hasConflict(ArrayList<ArrayList<String>> day, String start, String end) {
      for (ArrayList<String> time : day) {
        String myStart = time.get(0);
        String myEnd = time.get(1);
        if (myStart.get(0).length() == 4) {
            myStart.set(0, "0" + myStart.get(0));
        }

        if (myEnd.get(0).length() == 4) {
            myEnd.set(0, "0" + myEnd.get(0));
        }

        if (start.get(0).length() == 4) {
            start.set(0, "0" + start.get(0));
        }

        if (end.get(0).length() == 4) {
            end.set(0, "0" + end.get(0));
        }

        if (end > myStart && start < myEnd) {
          return true;
        }
      }
      return false;
    }



    HashSet<String[]> conflicts = new HashSet<>();  // {[title, course_id]: [[conf_title, conf_ourse_id], ], ...}

    String start = "";
    String end = "";
    String other_days = "";
    String title = "";
    String course_id = "";
    
    Statement stmt_other = conn.createStatement();
    ResultSet rs_other = stmt_other.executeQuery("select c.section_id, c.title, c.course_id, m.days, m.start_time, m.end_time from classes c join meetings m on c.section_id = m.section_id where quarter = 'Spring 2018' and c.section_id not in (select section_id from taking)");
    while (rs_other.next()) {
        // check if there is a conflict
        start = rs_other.getString("start_time");
        end = rs_other.getString("end_time");
        other_days = rs_other.getString("days");
        title = rs_other.getString("title");
        course_id = rs_other.getString("course_id");

        // For each day this meeting takes place, check if there is a conflict with the student's current classes
        if (other_days.contains("M") && hasConflict(monday, start, end)) {
            conflicts.add(new String[] {title, course_id});
        }
        else if (other_days.contains("Tu") && hasConflict(tuesday, start, end)) {
            conflicts.add(new String[] {title, course_id});
        }
        else if (other_days.contains("W") && hasConflict(wednesday, start, end)) {
            conflicts.add(new String[] {title, course_id});
        }
        else if (other_days.contains("Th") && hasConflict(thursday, start, end)) {
            conflicts.add(new String[] {title, course_id});
        }
        else if (other_days.contains("F") && hasConflict(friday, start, end)) {
            conflicts.add(new String[] {title, course_id});
        }



    }

%>

<h2>Conflicts</h2>


<%-- <br><code>Close connection code</code> --%>
<%
    //rs.close();
    stmt_ssn.close();
    pstmt_student.close();
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