<html>
<HEAD><TITLE>CSE132B Webapp: Section</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Section Entry Form</FONT> <P />

<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="class.jsp" method="POST">
                <input type="submit" value="Class Entry Form"/>
            </form>
        </td>
    </tr>
    
    <tr>
        <td>
        Adding section(s) for <%= request.getParameter("class_name") %> <%= " with ID " + request.getParameter("class_id") %>
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
                ArrayList<String> day_list = new ArrayList<String>();
                ArrayList<String> time_list = new ArrayList<String>();
                ArrayList<String> building_and_room_list = new ArrayList<String>();
                ArrayList<String> instructor_list = new ArrayList<String>();
                ArrayList<Integer> section_id_list = new ArrayList<Integer>();
                pstmt = conn.prepareStatement("SELECT * FROM sections");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    section_id_list.add(rs2.getInt("section_id"));
                }
                pstmt = conn.prepareStatement("SELECT * FROM days");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    day_list.add(rs2.getString("day"));
                }
                pstmt = conn.prepareStatement("SELECT * FROM times");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    time_list.add(rs2.getString("time"));
                }
                pstmt = conn.prepareStatement("SELECT * FROM buildings");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    building_and_room_list.add(rs2.getString("building_and_room"));
                }
                pstmt = conn.prepareStatement("SELECT * FROM faculty");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    instructor_list.add(rs2.getString("faculty_name"));
                }
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    String insert_section_id = request.getParameter("section_id");
                    String insert_class_id = request.getParameter("class_id");
                    String insert_meeting_type = request.getParameter("meeting_type");
                    String insert_day = request.getParameter("day");
                    String insert_time = request.getParameter("time");
                    String insert_building_and_room = request.getParameter("building_and_room");
                    String insert_section_limit = request.getParameter("section_limit");
                    String insert_instructor = request.getParameter("instructor");

                    if(insert_section_id.equals("") || insert_meeting_type.equals("def") || insert_day.equals("def") ||
                       insert_time.equals("def") || insert_building_and_room.equals("def") || insert_section_limit.equals("") ||
                       insert_instructor.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_section_id.equals("")){
                        %>
                            <%= "Please enter a section id<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_meeting_type.equals("def")){
                        %>
                            <%= "Please choose a meeting type<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_day.equals("def")){
                        %>
                            <%= "Please enter a meeting day(s)<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_time.equals("def")){
                        %>
                            <%= "Please choose a time<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_building_and_room.equals("def")){
                        %>
                            <%= "Please choose a building and room<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_section_limit.equals("")){
                        %>
                            <%= "Please enter a section limit<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_instructor.equals("")){
                        %>
                            <%= "Please choose an instructor<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else if(insert_section_id.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Section ID must consists of numbers only<br />" %>
                        </ br>
                    <%
                    }
                    else if(section_id_list.contains(Integer.valueOf(insert_section_id))){
                    %>
                        <%= "Data Insertion Failure: Section ID must be unique<br />" %>
                        </ br>
                    <%
                    }
                    else if(insert_section_limit.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Section limit must consists of numbers only<br />" %>
                        </ br>
                    <%
                    }
                    else {
                        // Begin transaction
                        conn.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT student values INTO the students table.
                        pstmt = conn
                        .prepareStatement
                        ("INSERT INTO sections (section_id, class_id, instructor, section_limit, meeting_type, days, time, building_and_room)" +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

    					pstmt.setInt(1, Integer.parseInt(insert_section_id));
    					pstmt.setInt(2, Integer.parseInt(insert_class_id));
                        pstmt.setString(3, insert_instructor);
                        pstmt.setInt(4, Integer.parseInt(insert_section_limit));
                        pstmt.setString(5, insert_meeting_type);
                        pstmt.setString(6, insert_day);
                        pstmt.setString(7, insert_time);
                        pstmt.setString(8, insert_building_and_room);
                        int rowCount = pstmt.executeUpdate();

                        // Commit transaction
                        conn.commit();
                        conn.setAutoCommit(true);
                    }
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM sections WHERE class_id = ?");
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
				<th>Section ID</th>
				<th>Class ID</th>
                <th>Meeting Type</th>
                <th>Days</th>
                <th>Time</th>
                <th>Building and Room</th>
                <th>Section Limit</th>
                <th>Instructor</th>
            </tr>

            <tr>
                <form action="sections.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <input type="hidden" name="class_id" value="<%=request.getParameter("class_id")%>">
                    <input type="hidden" name="class_name" value="<%=request.getParameter("class_name")%>">
                    <th><input value="" name="section_id" size="10"/></th>
					<th> <%= request.getParameter("class_id") %> </th>
                    <th>
                        <select name="meeting_type">
                            <option value="def">--SELECT ONE--</option>
                            <option value="LE">LE</option>
                            <option value="DI">DI</option>
                        </select>
                    </th>
                    <th>
                        <select name="day">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: day_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="time">
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
                        <select name="building_and_room">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: building_and_room_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input value="" name="section_limit" size="15"/></th>
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
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
				<%-- Get the section id --%>
                <td>
                    <%= rs.getInt("section_id") %>
                </td>
				
				<%-- Get the clas id --%>
                <td>
                    <%= rs.getInt("class_id") %>
                </td>

                <%-- Get the meeting type --%>
                <td>
                    <%= rs.getString("meeting_type") %>
                </td>

                <%-- Get the days --%>
                <td>
                    <%= rs.getString("days") %>
                </td>

                <%-- Get the time --%>
                <td>
                    <%= rs.getString("time") %>
                </td>

                <%-- Get the building and room--%>
                <td>
                    <%= rs.getString("building_and_room") %>
                </td>

                <%-- Get the seciton limit --%>
                <td>
                    <%= rs.getInt("section_limit") %>
                </td>

                <%-- Get the instructor --%>
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

