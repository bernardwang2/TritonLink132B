<html>
<HEAD><TITLE>CSE132B Webapp: Section Enrollment Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Section Enrollment Form</FONT> <P />

<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="home.jsp" method="POST">
                <input type="submit" value="Home"/>
            </form>
        </td>
    </tr>

    <!-- Show Field Constraints -->
    <tr>
        <td>
            <%-- Import the java.sql package --%>
            <%@ page import="java.sql.*"%>
            <%@ page import="java.util.ArrayList"%>
            <%@ page import="java.util.List"%>

            <%-- -------- Open Connection Code -------- --%>
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String current_quarter = "Spring";
            int current_year = 2017;


            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
                String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(dbURL);

                // Get all options
                ArrayList<Integer> section_id_list = new ArrayList<Integer>();
                pstmt = conn.prepareStatement("SELECT * FROM sections_new ORDER BY section_id");
                rs = pstmt.executeQuery();
                while(rs.next()){
                    section_id_list.add(rs.getInt("section_id"));
                }
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
                    String insert_s_id = request.getParameter("s_id");
                    String insert_section_id = request.getParameter("section_id");
                    String insert_grade_option = request.getParameter("grade_option");
                    String insert_units = request.getParameter("units");

                    /* Get Next ID */
                    pstmt = conn.prepareStatement("SELECT MAX(history_id) AS history_id FROM academic_history_new");
                    rs = pstmt.executeQuery();
                    rs.next();
                    int insert_history_id = rs.getInt("history_id");
                    insert_history_id++;

                    /* Get Class ID */
                    pstmt = conn.prepareStatement(
                    "SELECT c.class_id FROM sections_new s, classes c " +
                    "WHERE s.section_id = ? AND s.course_number = c.class_name AND class_year = ? AND class_quarter = ?");
                    pstmt.setInt(1, Integer.parseInt(insert_section_id));
                    pstmt.setInt(2, current_year);
                    pstmt.setString(3, current_quarter);
                    rs = pstmt.executeQuery();
                    rs.next();
                    int insert_class_id = rs.getInt("class_id");

                    pstmt = conn.prepareStatement(
                    "INSERT INTO academic_history_new (history_id, s_id, class_id, grade_opt, grade, units, section_id) " +
                    "VALUES (?, ?, ?, ?, 'IN', ?, ?)"
                    );
                    pstmt.setInt(1, insert_history_id);
                    pstmt.setInt(2, Integer.parseInt(insert_s_id));
                    pstmt.setInt(3, insert_class_id);
                    pstmt.setString(4, insert_grade_option);
                    pstmt.setInt(5, Integer.parseInt(insert_units));
                    pstmt.setInt(6, Integer.parseInt(insert_section_id));
                    pstmt.executeUpdate();
                }
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Name</th>
                <th>Section ID</th>
                <th>Course Number</th>
                <th>Grade Option</th>
                <th>Units</th>
            </tr>

            <tr>
                <form action="section_enrollment.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th>
                        <select name="s_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            pstmt = conn.prepareStatement("SELECT * FROM students");
                            rs = pstmt.executeQuery();
                            while(rs.next()){
                            %>
                                <option value="<%= rs.getInt("s_id") %>"><%= rs.getString("first_name") + " " + rs.getString("last_name") %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="section_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(int s: section_id_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%
                            }
                            %>
                        </select>
                    </th>
                    <th></th>
                    <th>
                        <select name="grade_option">
                            <option value="def">--SELECT ONE--</option>
                            <option value="Letter Grade">Letter Grade</option>
                            <option value="S/U">S/U</option>
                            <option value="Letter Grade or S/U">Letter Grade or S/U</option>
                        </select>
                    </th>
                    <th>
                        <select name="units">
                            <option value="def">--SELECT ONE--</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>



            <%-- -------- SELECT Statement Code -------- --%>
            <%
                pstmt = conn.prepareStatement(
                "SELECT s.first_name, sn.section_id, sn.course_number, r.grade_opt, r.units " +
                "FROM academic_history_new r, students s, sections_new sn " +
                "WHERE r.grade = 'IN' AND r.s_id = s.s_id AND r.section_id = sn.section_id " +
                "ORDER BY r.section_id"
                );
                rs = pstmt.executeQuery();

                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
                <td>
                    <%= rs.getString("first_name") %>
                </td>
                <td>
                    <%= rs.getInt("section_id") %>
                </td>
                <td>
                    <%= rs.getString("course_number") %>
                </td>
                <td>
                    <%= rs.getString("grade_opt") %>
                </td>
                <td>
                    <%= rs.getInt("units") %>
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
        </td>
    </tr>
</table>
</body>

</html>

