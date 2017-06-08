<html>
<HEAD><TITLE>CSE132B Webapp: Section Schedule Insertion Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Section Schedule Insertion Form</FONT> <P />

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
            <%@ page import="java.text.SimpleDateFormat"%>
            <%@ page import="java.util.Date"%>
            <%@ page import="java.util.Calendar"%>

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



                ArrayList<String> current_class_list = new ArrayList<String>();
                ArrayList<String> instructor_list = new ArrayList<String>();
                ArrayList<String> time_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM classes WHERE class_year = ? AND class_quarter = ?");
                pstmt.setInt(1, current_year);
                pstmt.setString(2, current_quarter);
                rs = pstmt.executeQuery();
                while(rs.next()){
                    current_class_list.add(rs.getString("class_name"));
                }

                pstmt = conn.prepareStatement("SELECT * FROM faculty");
                rs = pstmt.executeQuery();
                while(rs.next()){
                    instructor_list.add(rs.getString("faculty_name"));
                }

                pstmt = conn.prepareStatement("SELECT * FROM times");
                rs = pstmt.executeQuery();
                while(rs.next()){
                    time_list.add(rs.getString("start_time"));
                }
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
                    String insert_section_id = request.getParameter("section_id");
                    String insert_course_number = request.getParameter("class_name");
                    String insert_quarter = "Spring";
                    String insert_year = "2017";
                    String insert_le_days = request.getParameter("le_days");
                    String insert_le_time = request.getParameter("le_time");
                    String insert_le_end_time = null;
                    String insert_di_days = request.getParameter("di_days");
                    String insert_di_time = request.getParameter("di_time");
                    String insert_di_end_time = null;
                    String insert_lab_days = request.getParameter("lab_days");
                    String insert_lab_time = request.getParameter("lab_time");
                    String insert_lab_end_time = null;
                    String insert_instructor = request.getParameter("instructor");
                    String insert_le_mon  = "n";
                    String insert_le_tues = "n";
                    String insert_le_wed  = "n";
                    String insert_le_thur = "n";
                    String insert_le_fri  = "n";
                    String insert_di_mon  = "n";
                    String insert_di_tues = "n";
                    String insert_di_wed  = "n";
                    String insert_di_thur = "n";
                    String insert_di_fri  = "n";
                    String insert_lab_mon  = "n";
                    String insert_lab_tues = "n";
                    String insert_lab_wed  = "n";
                    String insert_lab_thur = "n";
                    String insert_lab_fri  = "n";

                    /* Increment Time */
                    String pattern = "HH:mm:ss";
                    SimpleDateFormat formatter = new SimpleDateFormat(pattern);
                    Date date1 = formatter.parse(insert_le_time);
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(date1);
                    calendar.add(Calendar.HOUR, 1);
                    insert_le_end_time = formatter.format(calendar.getTime());

                    if(!insert_di_time.equals("def")){
                        Date date2 = formatter.parse(insert_di_time);
                        calendar.setTime(date2);
                        calendar.add(Calendar.HOUR, 1);
                        insert_di_end_time = formatter.format(calendar.getTime());
                    }
                    else{
                        insert_di_days = null;
                        insert_di_time = null;
                        insert_di_end_time = null;
                    }
                    if(!insert_lab_time.equals("def")){
                        Date date3 = formatter.parse(insert_lab_time);
                        calendar.setTime(date3);
                        calendar.add(Calendar.HOUR, 1);
                        insert_lab_end_time = formatter.format(calendar.getTime());
                    }
                    else{
                        insert_lab_days = null;
                        insert_lab_time = null;
                        insert_lab_end_time = null;
                    }
                    
                    pstmt = conn.prepareStatement(
                    "INSERT INTO sections_new (section_id, course_number, quarter, year, instructor, " +
                    "le_days, lec_start_time, lec_end_time, di_days, dis_start_time, dis_end_time, " +
                    "lab_days, lab_start_time, lab_end_time) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    );
                    pstmt.setInt(1, Integer.parseInt(insert_section_id));
                    pstmt.setString(2, insert_course_number);
                    pstmt.setString(3, insert_quarter);
                    pstmt.setInt(4, Integer.parseInt(insert_year));
                    pstmt.setString(5, insert_instructor);
                    
                    pstmt.setString(6, insert_le_days);
                    pstmt.setTime(7, Time.valueOf(insert_le_time));
                    pstmt.setTime(8, Time.valueOf(insert_le_end_time));
                    
                    if(insert_di_time != null){
                        pstmt.setString(9, insert_di_days);
                        pstmt.setTime(10, Time.valueOf(insert_di_time));
                        pstmt.setTime(11, Time.valueOf(insert_di_end_time));
                    }
                    else{
                        pstmt.setString(9, null);
                        pstmt.setTime(10, null);
                        pstmt.setTime(11, null);
                    }
                    
                    if(insert_lab_time != null){
                        pstmt.setString(12, insert_lab_days);
                        pstmt.setTime(13, Time.valueOf(insert_lab_time));
                        pstmt.setTime(14, Time.valueOf(insert_lab_end_time));
                    }
                    else{
                        pstmt.setString(12, null);
                        pstmt.setTime(13, null);
                        pstmt.setTime(14, null);
                    }
                    
                    pstmt.executeUpdate();

                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                pstmt = conn.prepareStatement("SELECT * FROM sections_new ORDER BY section_id");
                rs = pstmt.executeQuery();
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Section ID</th>
                <th>Course Number</th>
                <th>Quarter</th>
                <th>Year</th>
                <th>Lecture Days</th>
                <th>Lecture Time</th>
                <th>Discussion Days</th>
                <th>Discussion Time</th>
                <th>Lab Days</th>
                <th>Lab Time</th>
                <th>Instructor</th>
            </tr>

            <tr>
                <form action="insertion.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="section_id" size="15"/></th>
                    <th>
                        <select name="class_name">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: current_class_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th>Spring</th>
                    <th>2017</th>
                    <th><input value="" name="le_days" size="15"/></th>
                    <th>
                        <select name="le_time">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: time_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input value="" name="di_days" size="18"/></th>
                    <th>
                        <select name="di_time">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: time_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input value="" name="lab_days" size="15"/></th>
                    <th>
                        <select name="lab_time">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: time_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="instructor">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: instructor_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input type="submit" value="Insert New Section"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
                <td>
                    <%= rs.getInt("section_id") %>
                </td>
                <td>
                    <%= rs.getString("course_number") %>
                </td>
                <td>
                    <%= rs.getString("quarter") %>
                </td>
                <td>
                    <%= rs.getInt("year") %>
                </td>
                <td>
                    <%= rs.getString("le_days") %>
                </td>
                <td>
                    <%= rs.getString("lec_start_time") %>
                </td>
                <td>
                    <% if(rs.getString("di_days") != null) { %>
                    <%= rs.getString("di_days") %>
                    <% }else{ %>
                    <%= "--" %>
                    <%}%>
                </td>
                <td>
                    <% if(rs.getString("dis_start_time") != null) { %>
                    <%= rs.getString("dis_start_time") %>
                    <% }else{ %>
                    <%= "--" %>
                    <%}%>
                </td>
                <td>
                    <% if(rs.getString("lab_days") != null) { %>
                    <%= rs.getString("lab_days") %>
                    <% }else{ %>
                    <%= "--" %>
                    <%}%>
                </td>
                <td>
                    <% if(rs.getString("lab_start_time") != null) { %>
                    <%= rs.getString("lab_start_time") %>
                    <% }else{ %>
                    <%= "--" %>
                    <%}%>
                </td>
                <td>
                    <%= rs.getString("instructor") %>
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

