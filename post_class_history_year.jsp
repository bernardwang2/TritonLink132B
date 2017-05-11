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
                    String insert_grade = request.getParameter("grade");

                    // Begin transaction
                    conn.setAutoCommit(false);
                    pstmt = conn.prepareStatement
                    ("SELECT DISTINCT class_year FROM classes WHERE class_name = ? ORDER BY class_year");
                    pstmt.setString(1, insert_c_name);
                    rs = pstmt.executeQuery();
                    
                    ArrayList<String> year_list = new ArrayList<String>();
                    while(rs.next()){
                        year_list.add(rs.getString("class_year"));
                    }

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
            %>
            <p>Student ID: <%= insert_s_id %>, Class: <%= insert_c_name %></p>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
            <tr>
                <th>Year</th>
            </tr>

            <tr>
                <form action="post_class_history_quarter.jsp" method="POST">
                    <input type="hidden" name="action" value="next"/>
                    <input type="hidden" name="s_id" value="<%= insert_s_id %>"/>
                    <input type="hidden" name="c_name" value="<%= insert_c_name %>"/>
                    <input type="hidden" name="grade" value="<%= insert_grade %>"/>
                    <th>
                        <select name="class_year">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: year_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input type="submit" value="Next"/></th>
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

