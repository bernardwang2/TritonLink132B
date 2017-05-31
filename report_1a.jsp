<html>
<HEAD><TITLE>CSE132B Webapp: Report 1a</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 1a</FONT> <P />



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

    // Retrieve currently enrolled students
    pstmt = conn.prepareStatement("SELECT s.ssn, s.first_name, s.last_name " +
                                  "FROM students s " +
                                  "WHERE s.s_id IN " +
                                  " (SELECT r.s_id" +
                                  "  FROM academic_history_new r " +
                                  "  WHERE r.grade = 'IN') " +
                                  "ORDER BY s.ssn");
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
                <form action="report_1a.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the classes currently taken by student: </p>
                </td>

                <td>
                    <select name="selected_student">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs.next()){
                %>
                        <option value="<%= rs.getInt("ssn") %>"><%= rs.getInt("ssn") +" "+rs.getString("first_name")+" "+rs.getString("last_name") %></option>
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

        // Retrieve the name and s_id of the selected student
        String selected_ssn = request.getParameter("selected_student");
        pstmt = conn.prepareStatement("SELECT * FROM students WHERE ssn = ?");
        pstmt.setInt(1, Integer.parseInt(selected_ssn));
        rs = pstmt.executeQuery();
        rs.next();
        int selected_sid = rs.getInt("s_id");
        String selected_name = rs.getString("first_name") + " " + rs.getString("last_name");

        // Retrieve the classes currently taken by the selected student
        pstmt = conn.prepareStatement("SELECT c.class_id, c.class_name, c.class_title, c.class_year, c.class_quarter, r.units, r.section_id " +
                                      "FROM academic_history_new r, sections_new s, classes c " +
                                      "WHERE r.s_id = ? AND r.section_id = s.section_id AND s.course_number = c.class_name AND " +
                                            "c.class_year = ? AND c.class_quarter = ? " +
                                      "ORDER BY c.class_id");
        pstmt.setInt(1, selected_sid);
        pstmt.setInt(2, current_year);
        pstmt.setString(3, current_quarter);
        rs = pstmt.executeQuery();
%>
    <tr>
        <td>
            <%= selected_name %> is taking
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Class ID</th>
                    <th>Course Number</th>
                    <th>Class Title</th>
                    <th>Class Year</th>
                    <th>Class Quarter</th>
                    <th>Section ID</th>
                    <th>Units</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

                <tr>
                    <%-- Get the class_id --%>
                    <td>
                        <%= rs.getInt("class_id") %>
                    </td>
                    <%-- Get the course_number --%>
                    <td>
                        <%= rs.getString("class_name") %>
                    </td>
                    <%-- Get the class_title --%>
                    <td>
                        <%= rs.getString("class_title") %>
                    </td>
                    <%-- Get the class_year --%>
                    <td>
                        <%= rs.getInt("class_year") %>
                    </td>
                    <%-- Get the class_quarter --%>
                    <td>
                        <%= rs.getString("class_quarter") %>
                    </td>
                    <%-- Get the section_id --%>
                    <td>
                        <%= rs.getInt("section_id") %>
                    </td>
                    <%-- Get the units --%>
                    <td>
                        <%= rs.getInt("units") %>
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

