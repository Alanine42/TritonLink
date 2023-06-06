<%@ page language="java" import="java.sql.*"  %>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.Integer" %>


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
    // Fetch section IDS of all students enrolled in the current quarter (Spring 2018)
    Statement stmt_sec = conn.createStatement();
    ResultSet rs_sec = stmt_sec.executeQuery("select section_id from classes where section_id in (select distinct section_id from course_enrollment) order by section_id");
    ArrayList<Integer> secs = new ArrayList<Integer>();
    while (rs_sec.next()) {
        secs.add(rs_sec.getInt("section_id"));
    }
%>
<%-- Select section by their section_id --%>
<form action="review_session_schedule.jsp" method="post">         
    <select name="sec" id="sec_insert">
      <option value="">-- select section --</option>
      <% for (int sec : secs) { %>
        <option value=<%= sec %>><%= sec %></option>
      <% } %>
    </select>
  <input type="submit" value="Get available timeslots for this section's review session">
</form>

<%

    int section = request.getParameter("sec")==null ? 0 : Integer.parseInt(request.getParameter("sec"));

    PreparedStatement pstmt_course = conn.prepareStatement("select distinct course_id from classes where section_id=?");
    pstmt_course.setInt(1, section);
    ResultSet rs_course = pstmt_course.executeQuery();
    String course = "";
    if (rs_course.next()) {
        course = (rs_course.getString("course_id"));
    }
%>


<%
    String day = "";
    String start_time = "";
    String end_time = "";
    String start_time_hour = "";
    String[] end_time_arr = new String[2];
    PreparedStatement pstmt_meet = conn.prepareStatement("select distinct all_meetings.day, all_meetings.start_time, all_meetings.end_time from (select section_id, day, start_time, end_time from review_sessions union select section_id, day, start_time, end_time from meetings) as all_meetings where section_id in (select distinct section_id from course_enrollment where student_id in  (select distinct student_id from classes where section_id=?))");
    
    boolean[] monday = new boolean[12];
    boolean[] tuesday = new boolean[12];
    boolean[] wednesday = new boolean[12];
    boolean[] thursday = new boolean[12];
    boolean[] friday = new boolean[12];

    pstmt_meet.setInt(1, section);
    ResultSet rs_meet = pstmt_meet.executeQuery();
    while (rs_meet.next()) {
        day = rs_meet.getString("day");
        start_time = rs_meet.getString("start_time");
        end_time = rs_meet.getString("end_time");
        start_time_hour = start_time.split(":")[0];
        end_time_arr = end_time.split(":");
        int end_time_int = Integer.parseInt(end_time_arr[0]);
        if(!(end_time_arr[1].equals("00"))){
            end_time_int += 1;
        }
        int start_time_int = Integer.parseInt(start_time_hour);
        for (int i = start_time_int; i < end_time_int; i++){
            if (day.equals("M")){
                monday[i - 8] = true;
            }
            else if (day.equals("Tu")){
                tuesday[i - 8] = true;
            }
            else if (day.equals("W")){
                wednesday[i - 8] = true;
            }
            else if (day.equals("Th")){
                thursday[i - 8] = true;
            }
            else if (day.equals("F")){
                friday[i - 8] = true;
            }
        }
    }

%>  
    <p>Section: <%= section %></p><br>
    <p>Course: <%= course %></p>
    <table>
     <th>Available Times</th>
      <%
        for(int i = 0; i < 12; i++){
          if (!monday[i]){
      %>
      <tr>June 4 Monday <%= String.valueOf(i + 8)%>:00 - <%= String.valueOf(i + 9)%>:00</tr><br> 
      <%
          }
        }
      %>
      <%
        for(int i = 0; i < 12; i++){
          if (!tuesday[i]){
      %>
      <tr>June 5 Tuesday <%= String.valueOf(i + 8)%>:00 - <%= String.valueOf(i + 9)%>:00</tr><br>
      <%
          }
        }
      %>
      <%
        for(int i = 0; i < 12; i++){
          if (!wednesday[i]){
      %>
      <tr>June 6 Wednesday <%= String.valueOf(i + 8)%>:00 - <%= String.valueOf(i + 9)%>:00</tr><br>
      <%
          }
        }
      %>
      <%
        for(int i = 0; i < 12; i++){
          if (!thursday[i]){
      %>
      <tr>June 7 Thursday <%= String.valueOf(i + 8)%>:00 - <%= String.valueOf(i + 9)%>:00</tr><br>
      <%
          }
        }
      %>
      <%
        for(int i = 0; i < 12; i++){
          if (!friday[i]){
      %>
      <tr>June 8 Friday <%= String.valueOf(i + 8)%>:00 - <%= String.valueOf(i + 9)%>:00</tr><br>
      <%
          }
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
    out.println(e.getStackTrace()[0]);
  }

%>