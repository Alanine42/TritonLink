<html>

<head>
  <link rel="stylesheet" type="text/css" href="styles.css">
</head>

<body>
  <h2>Welcome to CSE 132B</h2>

  <table>
    <tr>
      <%-- Left column is menu --%>
      <td>
        <jsp:include page="menu.html" />
      </td>

      <%-- Right column is display --%>
      <td id="display">
      <%
        // Which page does the user want?
        String type = request.getParameter("type");
        if (type == null) {
          type = "students";
        }
        // delegate to students.jsp, courses.jsp, ...
        pageContext.include(type + ".jsp");
        
        %>
       

        
       

      </td>
    </tr>

  </table>

</body>

</html>