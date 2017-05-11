<html>
<HEAD><TITLE>CSE132B Webapp: Review Session Info Submission</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Probation Info Submission</FONT> <P />

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

                // Get all options
                ArrayList<String> class_id_list = new ArrayList<String>();
                ArrayList<String> date_list = new ArrayList<String>();
                ArrayList<String> time_list = new ArrayList<String>();
                ArrayList<String> building_and_room_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM classes WHERE class_year = ? AND class_quarter = ?");
                pstmt.setInt(1, current_year);
                pstmt.setString(2, current_quarter);
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    class_id_list.add(Integer.toString(rs2.getInt("class_id")));
                }
                pstmt = conn.prepareStatement("SELECT * FROM dates");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    date_list.add(rs2.getString("date"));
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
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    String insert_class_id = request.getParameter("class_id");
                    String insert_date = request.getParameter("date");
                    String insert_time = request.getParameter("time");
                    String insert_building_and_room = request.getParameter("building_and_room");

                    if(insert_class_id.equals("def") || insert_date.equals("def") || insert_time.equals("def") ||
                       insert_building_and_room.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_class_id.equals("def")){
                        %>
                            <%= "Please choose a class<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_date.equals("def")){
                        %>
                            <%= "Please choose a date<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_time.equals("def")){
                        %>
                            <%= "Please choose a time<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_building_and_room.equals("")){
                        %>
                            <%= "Please enter the building and room<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else {
                        // Begin transaction
                        conn.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT student values INTO the students table.
                        pstmt = conn
                        .prepareStatement
                        ("INSERT INTO review_sessions (class_id, date, time, building_and_room) VALUES (?, ?, ?, ?)");

    					pstmt.setInt(1, Integer.parseInt(insert_class_id));
                        pstmt.setString(2, insert_date);
    					pstmt.setString(3, insert_time);
    					pstmt.setString(4, insert_building_and_room);
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

                // Create the prepared statement and use it to
                // INSERT student values INTO the students table.
                pstmt = conn
                .prepareStatement("SELECT * FROM review_sessions");
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
				<th>ID</th>
                <th>Class ID</th>
				<th>Date</th>
				<th>Time</th>
				<th>Building and Room</th>
            </tr>

            <tr>
                <form action="review_session.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th></th>
                    <th>
                        <select name="class_id">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: class_id_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%
                            }
                            %>
                        </select>
                    </th>
                    <th>
                        <select name="date">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: date_list){
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
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
				<%-- Get the id --%>
                <td>
                    <%= rs.getInt("rs_id") %>
                </td>
				
                <%-- Get the clas id --%>
                <td>
                    <%= rs.getInt("class_id") %>
                </td>
				
				<%-- Get the date --%>
                <td>
                    <%= rs.getString("date") %>
                </td>
				
				<%-- Get the time --%>
                <td>
                    <%= rs.getString("time") %>
                </td>
				
				<%-- Get the building and room --%>
                <td>
                    <%= rs.getString("building_and_room") %>
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

