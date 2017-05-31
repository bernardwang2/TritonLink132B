<html>
<HEAD><TITLE>CSE132B Webapp: Report 1b</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 1b</FONT> <P />



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

    // Begin transaction
    conn.setAutoCommit(false);
    pstmt = conn.prepareStatement("SELECT * " +
                                  "FROM classes c " +
								  "WHERE c.class_year = ? AND c.class_quarter = ? " +
                                  "ORDER BY c.class_id");
    pstmt.setInt(1, current_year);
    pstmt.setString(2, current_quarter);
    rs = pstmt.executeQuery();

    conn.commit();
    conn.setAutoCommit(true);
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
                <form action="report_1b.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the roster of class:</p>
                </td>

                <td>
                    <select name="selected_class">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs.next()){
                %>
                        <option value="<%= rs.getString("class_title") %>"><%= rs.getString("class_name") +" "+ current_quarter +" "+ current_year%></option>
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
    // Check if an insertion is requested
    if (action != null && action.equals("submit")) {
		String selected_title = request.getParameter("selected_class");
		
		pstmt = conn.prepareStatement("SELECT s.ssn, s.first_name, s.last_name, u.major AS degree_name, r.units, r.grade_opt " +
                                      "FROM classes c, academic_history_new r, students s, undergraduates u " +
                                      "WHERE c.class_title = ? AND c.class_year = ? AND c.class_quarter = ? AND " +
                                      "      c.class_id = r.class_id AND r.s_id = s.s_id AND r.s_id = u.s_id " +
                                      "UNION " +
                                      "SELECT s.ssn, s.first_name, s.last_name, u.degree AS degree_name, r.units, r.grade_opt " +
                                      "FROM classes c, academic_history_new r, students s, graduates u " +
                                      "WHERE c.class_title = ? AND c.class_year = ? AND c.class_quarter = ? AND " +
                                      "      c.class_id = r.class_id AND r.s_id = s.s_id AND r.s_id = u.s_id " +
                                      "ORDER BY ssn"
                                      );
		
		pstmt.setString(1, selected_title);
        pstmt.setInt(2, current_year);
        pstmt.setString(3, current_quarter);
        pstmt.setString(4, selected_title);
        pstmt.setInt(5, current_year);
        pstmt.setString(6, current_quarter);
        rs = pstmt.executeQuery();
%>
    <tr>
        <td>
            Displaying the students currently taking the course with title <%= selected_title %>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>SSN</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Degree</th>
                    <th>Units</th>
                    <th>Grade Option</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

                <tr>
                    <%-- Get the SSN --%>
                    <td>
                        <%= rs.getInt("ssn") %>
                    </td>
                    <%-- Get the first name--%>
                    <td>
                        <%= rs.getString("first_name") %>
                    </td>
                    <%-- Get the last name--%>
                    <td>
                        <%= rs.getString("last_name") %>
                    </td>
                    <%-- Get the degree --%>
                    <td>
                        <%= rs.getString("degree_name") %>
                    </td>
                    <%-- Get the units --%>
                    <td>
                        <%= rs.getInt("units") %>
                    </td>
                    <%-- Get the grade_option --%>
                    <td>
                        <%= rs.getString("grade_opt") %>
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

