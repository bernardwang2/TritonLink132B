<html>
<HEAD><TITLE>CSE132B Webapp: Probation Info Submission</TITLE></HEAD>
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
                ArrayList<String> year_list = new ArrayList<String>();
                ArrayList<String> quarter_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM students");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    s_id_list.add(Integer.toString(rs2.getInt("s_id")));
                }
                pstmt = conn.prepareStatement("SELECT * FROM years");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    year_list.add(Integer.toString(rs2.getInt("year")));
                }
                pstmt = conn.prepareStatement("SELECT * FROM quarters");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    quarter_list.add(rs2.getString("quarter"));
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
                    String insert_p_year = request.getParameter("year");
                    String insert_p_quarter = request.getParameter("quarter");
                    String insert_p_reason = request.getParameter("reason");

                    if(insert_s_id.equals("def") || insert_p_year.equals("def") || insert_p_quarter.equals("def") ||
                       insert_p_reason.equals("")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_s_id.equals("def")){
                        %>
                            <%= "Please choose a student id<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_p_year.equals("def")){
                        %>
                            <%= "Please choose a year<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_p_quarter.equals("def")){
                        %>
                            <%= "Please choose a quarter<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_p_reason.equals("")){
                        %>
                            <%= "Please enter the reason<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else{
                        // Begin transaction
                        conn.setAutoCommit(false);
                        pstmt = conn
                        .prepareStatement("INSERT INTO probations (s_id, p_year, p_quarter, p_reason) VALUES (?, ?, ?, ?)");
                        
    					pstmt.setInt(1, Integer.parseInt(insert_s_id));
    					pstmt.setInt(2, Integer.parseInt(insert_p_year));
    					pstmt.setString(3, insert_p_quarter);
    					pstmt.setString(4, insert_p_reason);
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
                pstmt = conn
                .prepareStatement("SELECT * FROM probations");
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>ID</th>
				<th>Student ID</th>
				<th>Year</th>
				<th>Quarter</th>
				<th>Reason</th>
            </tr>

            <tr>
                <form action="probation.jsp" method="POST" id="probation_form">
                    <input type="hidden" name="action" value="insert"/>
                    <th></th>
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
                        <select name="year">
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
					<th>
                        <select name="quarter">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: quarter_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%
                            }
                            %>
                        </select>
                    </th>
					<th><textarea rows="4" cols="130" name="reason" form="probation_form"></textarea></th>
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
                    <%= rs.getInt("probation_id") %>
                </td>
				
                <%-- Get the student id --%>
                <td>
                    <%= rs.getString("s_id") %>
                </td>
				
				<%-- Get the year --%>
                <td>
                    <%= rs.getInt("p_year") %>
                </td>
				
				<%-- Get the quarter --%>
                <td>
                    <%= rs.getString("p_quarter") %>
                </td>
				
				<%-- Get the reason --%>
                <td>
                    <%= rs.getString("p_reason") %>
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

