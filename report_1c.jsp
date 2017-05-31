<html>
<HEAD><TITLE>CSE132B Webapp: Report 1c</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 1c</FONT> <P />



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

    // Retrieve all the students who have enrolled at some point
    pstmt = conn.prepareStatement("SELECT s.ssn, s.first_name, s.last_name " +
                                  "FROM students s " +
                                  "WHERE s.s_id IN " +
                                  " (SELECT r.s_id" +
                                  "  FROM academic_history_new r) " +
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
                <form action="report_1c.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the grade report of student: </p>
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



    <!-- Display Academic History -->
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

        // Retrieve all the classes taken by the selected student
        pstmt = conn.prepareStatement("SELECT c.class_id, c.class_name, c.class_title, c.class_year, c.class_quarter, r.grade, r.units " +
                                      "FROM academic_history_new r, classes c " +
                                      "WHERE r.s_id = ? AND r.class_id = c.class_id " +
                                      "ORDER BY c.class_year ASC, c.class_quarter DESC");
        pstmt.setInt(1, selected_sid);
        rs = pstmt.executeQuery();
%>
    <tr>
        <td>
            <%= selected_name %>'s grade report
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
                    <th>Grade</th>
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
                    <%-- Get the grade --%>
                    <td>
                        <%= rs.getString("grade") %>
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

    <!-- Display GPA -->
    <%
        pstmt = conn.prepareStatement("SELECT c.class_year, c.class_quarter, CAST(AVG(g.number_grade) AS DECIMAL(10, 2)) AS number_grade " +
                                      "FROM academic_history_new r, classes c, grade_conversion g " +
                                      "WHERE r.s_id = ? AND r.class_id = c.class_id AND r.grade != 'IN' AND r.grade = g.letter_grade " +
                                      "GROUP BY c.class_year, c.class_quarter " +
                                      "ORDER BY c.class_year ASC, c.class_quarter DESC");
        pstmt.setInt(1, selected_sid);
        rs = pstmt.executeQuery();
    %>
    <tr>
        <td>
            <%= selected_name %>'s GPA by quarter
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Class Year</th>
                    <th>Class Quarter</th>
                    <th>GPA</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

                <tr>
                    <%-- Get the class_year --%>
                    <td>
                        <%= rs.getInt("class_year") %>
                    </td>
                    <%-- Get the class_quarter --%>
                    <td>
                        <%= rs.getString("class_quarter") %>
                    </td>
                    <%-- Get the average_gpa --%>
                    <td>
                        <%= rs.getString("number_grade") %>
                    </td>
                </tr>

            <%
                }
            %>
            </table>
        </td>
    </tr>

    <!-- Display Avg GPA -->
    <%
        pstmt = conn.prepareStatement("SELECT CAST(AVG(g.number_grade) AS DECIMAL(10, 2)) AS avg_grade " +
                                      "FROM academic_history_new r, grade_conversion g " +
                                      "WHERE r.s_id = ? AND r.grade != 'IN' AND r.grade = g.letter_grade " +
                                      "GROUP BY r.s_id");
        pstmt.setInt(1, selected_sid);
        rs = pstmt.executeQuery();
        double avg_gpa = 0.0;
        while(rs.next()){
            avg_gpa = rs.getDouble("avg_grade");
        }
    %>
    <tr>
        <td>
            <%= selected_name %>'s cumulative GPA: <%= avg_gpa %>
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

