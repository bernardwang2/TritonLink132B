<html>
<HEAD><TITLE>CSE132B Webapp: Report 1e</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 1e</FONT> <P />



<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>



<%-- -------- Open Connection Code -------- --%>
<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
int current_year = 2017;
String current_quarter = "Spring";

try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
    conn = DriverManager.getConnection(dbURL);

    // Retrieve all undergraduates
    pstmt = conn.prepareStatement("SELECT s.ssn, s.first_name, s.last_name " +
                                  "FROM students s " +
                                  "WHERE s.s_id IN " +
                                  " (SELECT g.s_id" +
                                  "  FROM graduates g) " +
                                  "ORDER BY s.ssn");
    rs = pstmt.executeQuery();

    // Retrieve all bachelor degrees
    pstmt = conn.prepareStatement("SELECT d.degree_name " +
                                  "FROM degrees d " +
                                  "WHERE d.degree_type = 'M.S'");
    rs2 = pstmt.executeQuery();
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
                <form action="report_1e.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the remaining degree requirements for:</p>
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
                    <p>in degree:</p>
                </td>

                <td>
                    <select name="selected_degree">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs2.next()){
                %>
                        <option value="<%= rs2.getString("degree_name") %>"><%= rs2.getString("degree_name") %></option>
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



    <!-- Display The Concentrations that the student has completed -->
<%
    String action = request.getParameter("action");
    if (action != null && action.equals("submit")) {

        // Get the student name and s_id
        String selected_ssn = request.getParameter("selected_student");
        pstmt = conn.prepareStatement("SELECT * FROM students WHERE ssn = ?");
        pstmt.setInt(1, Integer.parseInt(selected_ssn));
        rs = pstmt.executeQuery();
        rs.next();

        int selected_sid = rs.getInt("s_id");
        String selected_name = rs.getString("first_name") + " " + rs.getString("last_name");

        // Get all the concentrations that the selected student completed
        pstmt = conn.prepareStatement("SELECT a.concen_name " +
                                      "FROM cs_concen_categories a " +
                                      "WHERE EXISTS " +
                                      "  (SELECT d.concen_id " +
                                      "   FROM academic_history_new r, classes c, courses d, grade_conversion g " +
                                      "   WHERE r.s_id = ? AND r.grade != 'IN' AND r.class_id = c.class_id AND c.class_name = d.c_name AND " +
                                      "         d.concen_id = a.concen_id AND r.grade = g.letter_grade " +
                                      "   GROUP BY d.concen_id " +
                                      "   HAVING AVG(g.number_grade) >= a.min_gpa_in_those_courses AND SUM(r.units) >= a.min_units_required " +
                                      "  )");
        pstmt.setInt(1, selected_sid);
        rs = pstmt.executeQuery();
%>
    <tr>
        <td>
            <%= selected_name %> has completed the following concentrations:
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Concentration</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

                <tr>
                    <%-- Get the class_id --%>
                    <td>
                        <%= rs.getString("concen_name") %>
                    </td>
                </tr>

            <%
                }
            %>
            </table>
        </td>
    </tr>

    <!-- Display the classes not yet taken in each concentration -->
    <%
        pstmt = conn.prepareStatement("SELECT concen_id, concen_name FROM cs_concen_categories");
        rs = pstmt.executeQuery();

        // For each concentration, get the courses in that concentration not yet taken by the student
        while(rs.next()){
            int concen_id = rs.getInt("concen_id");
            String concen_name = rs.getString("concen_name");

            pstmt = conn.prepareStatement("SELECT c.c_name " +
                                          "FROM courses c " +
                                          "WHERE c.concen_id = ? AND c.c_name NOT IN " +
                                          "  (SELECT d.class_name " +
                                          "   FROM academic_history_new r, classes d " +
                                          "   WHERE r.s_id = ? AND r.class_id = d.class_id)"
                                          );
            pstmt.setInt(1, concen_id);
            pstmt.setInt(2, selected_sid);
            rs2 = pstmt.executeQuery();
    %>
    <tr>
        <td>
            Courses in concentration <%= concen_name %> not yet taken:
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Courses</th>
                    <th>Next Offer</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs2.next()) {
                    pstmt = conn.prepareStatement("SELECT * " +
                                                  "FROM classes c " +
                                                  "WHERE c.class_name = ? AND " +
                                                  "     ((c.class_year > 2017) OR (c.class_year = 2017 AND c.class_quarter = 'Fall'))");
                    pstmt.setString(1, rs2.getString("c_name"));
                    rs3 = pstmt.executeQuery();
            %>

                <tr>
                    <%-- Get the course name --%>
                    <td>
                        <%= rs2.getString("c_name") %>
                    </td>
                    <td>
                        <% if(rs3.next()){ %>
                        <%= rs3.getString("class_quarter") + ", " + rs3.getInt("class_year") %>
                        <% }
                        else {
                        %>
                        <%= "None" %>
                        <% } %>
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




<%
    }
%>



<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSet
    rs.close();
    rs2.close();

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

