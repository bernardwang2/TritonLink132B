<html>
<HEAD><TITLE>CSE132B Webapp: Classes Taken in the Past</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Classes Taken in the Past</FONT> <P />

<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="home.jsp" method="POST">
                <input type="submit" value="Home"/>
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
            ResultSet rs2 = null;
            


            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
				String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(dbURL);



                // Begin transaction
                conn.setAutoCommit(false);

                // Get all options
                ArrayList<String> s_id_list = new ArrayList<String>();
                ArrayList<String> course_list = new ArrayList<String>();
                ArrayList<String> grade_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM students");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    s_id_list.add(Integer.toString(rs2.getInt("s_id")));
                }
                pstmt = conn.prepareStatement("SELECT * FROM courses");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    course_list.add(rs2.getString("c_name"));
                }
                pstmt = conn.prepareStatement("SELECT * FROM grades");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    grade_list.add(rs2.getString("grade"));
                }
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    String insert_s_id = request.getParameter("s_id");
                    String insert_section_id = request.getParameter("section_id");
                    String insert_grade = request.getParameter("grade");
                    String insert_units = request.getParameter("units");

                    // Begin transaction
                    conn.setAutoCommit(false);
                    pstmt = conn
                    .prepareStatement("SELECT * FROM academic_history WHERE s_id = ? AND section_id = ?");
                    pstmt.setInt(1, Integer.parseInt(insert_s_id));
                    pstmt.setInt(2, Integer.parseInt(insert_section_id));
                    rs = pstmt.executeQuery();
                    
                    // Check if this row already exists
                    if(rs.next()){
                        pstmt = conn
                        .prepareStatement("UPDATE academic_history SET grade = ?, units = ? WHERE s_id = ? AND section_id = ?");
                        pstmt.setString(1, insert_grade);
                        pstmt.setInt(2, Integer.parseInt(insert_units));
                        pstmt.setInt(3, Integer.parseInt(insert_s_id));
                        pstmt.setInt(4, Integer.parseInt(insert_section_id));
                        int rowCount = pstmt.executeUpdate();
                    }
                    // Insert if it doesn't exist
                    else{
                        pstmt = conn
                        .prepareStatement("INSERT INTO academic_history (s_id, section_id, grade, units) VALUES (?, ?, ?, ?)");
    					pstmt.setInt(1, Integer.parseInt(insert_s_id));
    					pstmt.setInt(2, Integer.parseInt(insert_section_id));
    					pstmt.setString(3, insert_grade);
                        pstmt.setInt(4, Integer.parseInt(insert_units));
                        int rowCount = pstmt.executeUpdate();
                    }
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <table border="1">
            <tr>
                <th>Student ID</th>
                <th>Course</th>
                <th>Grade</th>
            </tr>
            <tr>
                <form action="post_class_history_year.jsp" method="POST">
                    <input type="hidden" name="action" value="next"/>
                    <th>
                        <select name="s_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: s_id_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="c_name">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: course_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
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
                    <th><input type="submit" value="Next"/></th>
                </form>
            </tr>
            </table>
        </td>
    </tr>
    
    <tr>
        <td>
            <p></p>
        </td>
    </tr>

    <!-- Table for academic history -->
    <tr>
        <td>
            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM academic_history WHERE grade IS NOT NULL");
                rs = pstmt.executeQuery();

                conn.commit();
                conn.setAutoCommit(true);
            %>

            <!-- Table of enrollments -->
            <table border="1">
            <tr>
				<th>Student ID</th>
                <th>Course</th>
                <th>Quarter</th>
                <th>Year</th>
                <th>Section ID</th>
                <th>Grade</th>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
                    // Begin transaction
                    conn.setAutoCommit(false);

                    int section_id = rs.getInt("section_id");
                    pstmt = conn.prepareStatement("SELECT * FROM sections WHERE section_id = ?");
                    pstmt.setInt(1, section_id);
                    rs2 = pstmt.executeQuery();
                    rs2.next();
                    int class_id = rs2.getInt("class_id");
                    pstmt = conn.prepareStatement("SELECT * FROM classes WHERE class_id = ?");
                    pstmt.setInt(1, class_id);
                    rs2 = pstmt.executeQuery();
                    rs2.next();

                    String class_name = rs2.getString("class_name");
                    int class_year = rs2.getInt("class_year");
                    String class_quarter = rs2.getString("class_quarter");

                    conn.commit();
                    conn.setAutoCommit(true);
            %>

            <tr>
				<%-- Get the student id --%>
                <td>
                    <%= rs.getInt("s_id") %>
                </td>
				
                <%-- Get the clas name --%>
                <td>
                    <%= class_name %>
                </td>

                <%-- Get the quarter --%>
                <td>
                    <%= class_quarter %>
                </td>

                <%-- Get the year --%>
                <td>
                    <%= class_year %>
                </td>

                <%-- Get the section id --%>
                <td>
                    <%= rs.getInt("section_id") %>
                </td>
				
				<%-- Get the grade --%>
                <td>
                    <%= rs.getString("grade") %>
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

