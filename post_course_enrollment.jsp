<html>
<HEAD><TITLE>CSE132B Webapp: Classes Taken in the Past</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Classes Taken in the Past</FONT> <P />

<table>
    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="class_history.jsp" method="POST">
                <input type="submit" value="Classes taken in the past"/>
            </form>
        </td>
    </tr>

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
            


            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
                String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(dbURL);
            %>
            
            <%-- -------- SELECT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("next")) {

                    String insert_s_id = request.getParameter("s_id");
                    String insert_c_name = request.getParameter("c_name");
                    String current_quarter = request.getParameter("current_quarter");
                    String current_year = request.getParameter("current_year");

                    // Begin transaction
                    conn.setAutoCommit(false);
                    pstmt = conn.prepareStatement("SELECT * FROM classes WHERE class_name = ? AND class_year = ? AND class_quarter = ?");
                    pstmt.setString(1, insert_c_name);
                    pstmt.setInt(2, Integer.parseInt(current_year));
                    pstmt.setString(3, current_quarter);
                    rs = pstmt.executeQuery();
                    rs.next();
                    int class_id = rs.getInt("class_id");

                    ArrayList<String> section_list = new ArrayList<String>();
                    ArrayList<String> unit_list = new ArrayList<String>();
                    pstmt = conn.prepareStatement("SELECT * FROM sections WHERE class_id = ?");
                    pstmt.setInt(1, class_id);
                    rs = pstmt.executeQuery();
                    while(rs.next()){
                        section_list.add(Integer.toString(rs.getInt("section_id")));
                    }
                    pstmt = conn.prepareStatement("SELECT * FROM courses WHERE c_name = ?");
                    pstmt.setString(1, insert_c_name);
                    rs = pstmt.executeQuery();
                    rs.next();
                    int c_unit_range = rs.getInt("c_unit_range");

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
            %>
            <p> Student ID: <%= insert_s_id %>, Class: <%= insert_c_name %>, Year: <%= current_year %>, Quarter: <%= current_quarter %></p>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
            <tr>
                <th>Section</th>
                <th>Units</th>
            </tr>

            <tr>
                <form action="course_enrollment.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <input type="hidden" name="s_id" value="<%= insert_s_id %>"/>
                    <th>
                        <select name="section_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: section_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="units">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(int i = 1; i <= c_unit_range; i++){
                                String s = Integer.toString(i);
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%
                            }
                            %>
                        </select>
                    </th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
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

