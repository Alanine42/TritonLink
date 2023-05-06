<html>

<head>
  <link rel="stylesheet" type="text/css" href="styles.css">
</head>

<body>
  <h2>Hello Wowowowowowoow</h2>

  <table>
    <tr>
      <%-- Left column is menu --%>
      <td>
        <jsp:include page="menu.html" />
      </td>

      <%-- Right column is display --%>
      <td id="display">
        <code>Open connection code</code>
        <%@ page language="java" import="java.sql.*"  %>

        <% 
          try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5433/tritonlinkDB", "postgres", "409621a");
            out.println("Connected to Postgres!");
 // [!] un/comment the line below to get syntax highlighting for below html codes. 
              //}
           
        %>  

        <br><code> Insertion code</code>
        <%
            String action = request.getParameter("action");
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);

              PreparedStatement pstmt = conn.prepareStatement(
                  "insert into students values (?, ?, ?, ?, ?)");
              pstmt.setString(1, request.getParameter("student_id"));
              pstmt.setString(2, request.getParameter("fname"));
              // [?] How to insert optional value (mname)?
              pstmt.setString(3, request.getParameter("lname"));
              pstmt.setString(4, request.getParameter("ssn"));
              pstmt.setString(5, request.getParameter("residency"));
              pstmt.executeUpdate();

              conn.commit();
              conn.setAutoCommit(true);
            }
        
        %>



        <br><code>Statement code</code>

        <%
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("select * from students");
        %>

        <br><code>Presentation code</code>
        <table>
          <tr>
            <th>Student ID</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>SSN</th>
            <th>Residency</th>
          </tr>

          <tr>
            <form action="index.jsp" method="get">         
            <%-- should be action="students.jsp"... or rather, ="undergraduates.jsp"... --%>
              <input type="hidden" name="action" value="insert">
              <td><input type="text" name="student_id" size="10"></td>
              <td><input type="text" name="fname" size="15"></td>
              <td><input type="text" name="lname" size="15"></td>
              <td><input type="text" name="ssn" size="10"></td>
              <td><input type="text" name="residency" size="15"></td>
              <td><input type="submit" value="Insert"></td>
            </form>
          </tr>

        <% 
          while (rs.next()) { 
            String student_id = rs.getString("student_id");
            String fname = rs.getString("fname");
            String lname = rs.getString("lname");
            String ssn = rs.getString("ssn");
            String residency = rs.getString("residency");
        %>
          <tr>
            <td><%= student_id %></td>
            <td><%= fname %></td>
            <td><%= lname %></td>
            <td><%= ssn %></td>
            <td><%= residency %></td>
          </tr>
        <%
          }
        %>
        
        
        </table>


        
        <br><code>Close connection code</code>
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

          out.println("Hello World! Here?? ");
        %>

      </td>
    </tr>

  </table>

</body>

</html>