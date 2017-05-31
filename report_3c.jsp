<html>
<HEAD><TITLE>CSE132B Webapp: Report 3c</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 3c</FONT> <P />



<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>



<%-- -------- Open Connection Code -------- --%>
<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
int current_year = 2017;
String current_quarter = "Spring";

try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
    conn = DriverManager.getConnection(dbURL);

    pstmt = conn.prepareStatement("SELECT * FROM courses ORDER BY c_id");
    rs = pstmt.executeQuery();
%>



<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="home.jsp" method="GET">
                <input type="submit" value="Home"/>
            </form>
        </td>
    </tr>



    <!-- User Prompt -->
    <tr>
        <td>
            <table>
                <form action="report_3c.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the count of grades of course: </p>
                </td>

                <td>
                    <select name="selected_course">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs.next()){
                %>
                        <option value="<%= rs.getString("c_name") %>"><%= rs.getString("c_name") %></option>
                <%
                    }
                %>
                    </select>
                </td>

                <td>
                    <input type="submit" value="Submit"/>
                </td>
            
                </form>
            </table>
        </td>
    </tr>



    <!-- Display Results -->
<%
    String action = request.getParameter("action");
    if (action != null && action.equals("submit")) {

        String selected_course = request.getParameter("selected_course");

        pstmt = conn.prepareStatement("SELECT r.grade, COUNT(r.history_id) AS count " +
                                      "FROM academic_history_new r " +
                                      "WHERE r.grade != 'IN' AND r.class_id IN " +
                                      "  (SELECT c.class_id " +
                                      "   FROM classes c " +
                                      "   WHERE c.class_name = ?) " +
                                      "GROUP BY r.grade " +
                                      "ORDER BY r.grade ASC"
                                      );
        pstmt.setString(1, selected_course);
        rs = pstmt.executeQuery();
%>

    <tr>
        <td>
            The following grades were given to the students who took course <%= selected_course %>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Grade</th>
                    <th>Count</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

                <tr>
                    <%-- Get the grade --%>
                    <td>
                        <%= rs.getString("grade") %>
                    </td>
                    <%-- Get the count --%>
                    <td>
                        <%= rs.getString("count") %>
                    </td>
                </tr>

            <%
                }
            %>
            </table>
        </td>
    </tr>
<%
    }
%>



<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSet
    rs.close();

    // Close the Connection
    conn.close();
} catch (SQLException e) {

    // Wrap the SQL exception in a runtime exception to propagate
    // it upwards
    throw new RuntimeException(e);
}
finally {
    // Release resources in a finally block in reverse-order of
    // their creation

    if (rs != null) {
        try {
            rs.close();
        } catch (SQLException e) { } // Ignore
        rs = null;
    }
    if (pstmt != null) {
        try {
            pstmt.close();
        } catch (SQLException e) { } // Ignore
        pstmt = null;
    }
    if (conn != null) {
        try {
            conn.close();
        } catch (SQLException e) { } // Ignore
        conn = null;
    }
}
%>
</table>
</body>

</html>

