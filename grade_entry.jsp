<html>
<HEAD><TITLE>CSE132B Webapp: Grade Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Grade Entry Form</FONT> <P />

<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="home.jsp" method="POST">
                <input type="submit" value="Home"/>
            </form>
        </td>
    </tr>

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



        // Get all options
        ArrayList<String> section_id_list = new ArrayList<String>();
        ArrayList<String> grade_list = new ArrayList<String>();
        pstmt = conn.prepareStatement("SELECT * FROM sections_new ORDER BY section_id");
        rs = pstmt.executeQuery();
        while(rs.next()){
            section_id_list.add(Integer.toString(rs.getInt("section_id")));
        }
        pstmt = conn.prepareStatement("SELECT * FROM grades");
        rs = pstmt.executeQuery();
        while(rs.next()){
            grade_list.add(rs.getString("grade"));
        }
    %>
    
    <%-- -------- INSERT Code -------- --%>
    <%
        String action = request.getParameter("action");
        // Check if an insertion is requested
        if (action != null && action.equals("insert")) {

            String insert_s_id = request.getParameter("s_id");
            String insert_grade = request.getParameter("grade");
            String insert_section_id = request.getParameter("section_id");
            String insert_grade_option = "Letter Grade";
            int insert_units = 4;

            /* History ID */
            pstmt = conn.prepareStatement("SELECT MAX(history_id) AS history_id FROM academic_history_new");
            rs = pstmt.executeQuery();
            rs.next();
            int insert_history_id = rs.getInt("history_id") + 1;

            /* Class ID based on insert_section_id */
            pstmt = conn.prepareStatement("SELECT c.class_id FROM sections_new s, classes c " +
            "WHERE s.section_id = ? AND s.course_number = c.class_name AND s.quarter = c.class_quarter AND s.year = c.class_year");
            pstmt.setInt(1, Integer.parseInt(insert_section_id));
            rs = pstmt.executeQuery();
            rs.next();
            int insert_class_id = rs.getInt("class_id");

            pstmt = conn.prepareStatement(
            "INSERT INTO academic_history_new (history_id, s_id, class_id, grade_opt, grade, " +
            "units, section_id) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)"
            );

            pstmt.setInt(1, insert_history_id);
            pstmt.setInt(2, Integer.parseInt(insert_s_id));
            pstmt.setInt(3, insert_class_id);
            pstmt.setString(4, insert_grade_option);
            pstmt.setString(5, insert_grade);
            pstmt.setInt(6, insert_units);
            pstmt.setInt(7, Integer.parseInt(insert_section_id));

            pstmt.executeUpdate();
            //out.println("INSERTED");
        }
    %>

    <%-- -------- UPDATE Code -------- --%>
    <%
        if (action != null && action.equals("update")) {

            String update_history_id = request.getParameter("history_id");
            String update_grade = request.getParameter("grade");

            pstmt = conn.prepareStatement("UPDATE academic_history_new SET grade = ? WHERE history_id = ?");

            pstmt.setString(1, update_grade);
            pstmt.setInt(2, Integer.parseInt(update_history_id));
            pstmt.executeUpdate();
            out.println("UPDATED " + update_history_id + " TO " + update_grade);
        }
    %>
    <tr>
        <td>
            <table border="1">
            <tr>
                <th>Hisotry ID</th>
                <th>Student</th>
                <th>Course Number</th>
                <th>Quarter</th>
                <th>Year</th>
                <th>Grade Option</th>
                <th>Grade</th>
                <th>Units</th>
                <th>Section ID</th>
            </tr>
            <tr>
                <form action="grade_entry.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th></th>
                    <th>
                        <select name="s_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            pstmt = conn.prepareStatement("SELECT * FROM students ORDER BY s_id");
                            rs = pstmt.executeQuery();
                            while(rs.next()){
                            %>
                                <option value="<%= rs.getInt("s_id") %>"><%= rs.getString("first_name") + " " + rs.getString("last_name") %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th>
                        <select name="grade">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: grade_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th></th>
                    <th>
                        <select name="section_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: section_id_list){
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

            <%-- -------- SELECT Code -------- --%>
            <%
                
                pstmt = conn.prepareStatement(
                "SELECT r.history_id, s.first_name, s.last_name, c.class_name, " +
                "c.class_quarter, c.class_year, r.grade_opt, r.grade, r.units, r.section_id " +
                "FROM academic_history_new r, classes c, students s " +
                "WHERE r.class_id = c.class_id AND r.s_id = s.s_id " +
                "ORDER BY r.history_id"
                );
                
                rs = pstmt.executeQuery();

                while(rs.next()){
            %>
            <tr>
            <form action="grade_entry.jsp" method="POST">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="history_id" value="<%=rs.getInt("history_id")%>"/>
                <td>
                    <%= rs.getInt("history_id") %>
                </td>
                <td>
                    <%= rs.getString("first_name") + " " + rs.getString("last_name") %>
                </td>
                <td>
                    <%= rs.getString("class_name") %>
                </td>
                <td>
                    <%= rs.getString("class_quarter") %>
                </td>
                <td>
                    <%= rs.getInt("class_year") %>
                </td>
                <td>
                    <%= rs.getString("grade_opt") %>
                </td>
                <td>
                    <input value="<%=rs.getString("grade")%>" name="grade" size="20"/>
                </td>
                <td>
                    <%= rs.getInt("units") %>
                </td>
                <td>
                    <% if(rs.getInt("section_id") != 0){ %>
                    <%= rs.getInt("section_id") %>
                    <%}else{ %>
                    <%= "--" %>
                    <% } %>
                </td>
                <td><input type="submit" value="Update"></td>
            </form>
            </tr>
            <%
            }
            %>
            </table>
        </td>
    </tr>
    
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

