<html>
<HEAD><TITLE>CSE132B Webapp: Report 3a</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 3a</FONT> <P />



<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>



<%-- -------- Open Connection Code -------- --%>
<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;
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

    pstmt = conn.prepareStatement("SELECT * FROM faculty");
    rs2 = pstmt.executeQuery();

    pstmt = conn.prepareStatement("SELECT * FROM years ORDER BY year");
    rs3 = pstmt.executeQuery();

    pstmt = conn.prepareStatement("SELECT * FROM quarters ORDER BY quarter ASC");
    rs4 = pstmt.executeQuery();
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
                <form action="report_3a.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the count of grades that professor: </p>
                </td>

                <td>
                    <select name="selected_professor">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs2.next()){
                %>
                        <option value="<%= rs2.getString("faculty_name") %>"><%= rs2.getString("faculty_name") %></option>
                <%
                    }
                %>
                    </select>
                </td>

                <td>
                    <p> gave at quarter: </p>
                </td>

                <td>
                    <select name="selected_quarter">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs4.next()){
                %>
                        <option value="<%= rs4.getString("quarter") %>"><%= rs4.getString("quarter") %></option>
                <%
                    }
                %>
                    </select>
                </td>

                <td>
                    <select name="selected_year">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs3.next()){
                %>
                        <option value="<%= rs3.getInt("year") %>"><%= rs3.getInt("year") %></option>
                <%
                    }
                %>
                    </select>
                </td>

                <td>
                    <p> to the students taking course: </p>
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
    
        String selected_professor = request.getParameter("selected_professor");
        String selected_course = request.getParameter("selected_course");
        String selected_quarter = request.getParameter("selected_quarter");
        String selected_year = request.getParameter("selected_year");

        pstmt = conn.prepareStatement("SELECT r.grade, COUNT(r.history_id) AS count " +
                                      "FROM academic_history_new r " +
                                      "WHERE r.class_id = " +
                                      "  (SELECT c.class_id " +
                                      "   FROM classes c " +
                                      "   WHERE c.instructor = ? AND c.class_name = ? AND c.class_year = ? AND c.class_quarter = ?) " +
                                      "GROUP BY r.grade"
                                      );
        pstmt.setString(1, selected_professor);
        pstmt.setString(2, selected_course);
        pstmt.setInt(3, Integer.parseInt(selected_year));
        pstmt.setString(4, selected_quarter);
        rs = pstmt.executeQuery();
%>

    <tr>
        <td>
            Professor <%= selected_professor %> gave the following grades at quarter <%= selected_quarter +" "+ selected_year %> to the students taking course <%= selected_course %>
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
    rs2.close();
    rs3.close();
    rs4.close();

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

