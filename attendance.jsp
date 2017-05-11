<html>

<HEAD><TITLE>CSE132B Webapp: Attendance </TITLE></HEAD>
<BODY>  <FONT SIZE="5">Attendance</FONT> <P />


<table>

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
			ResultSet rs1 = null;
            
            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
				String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(
                    dbURL);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
					String insert_s_id = request.getParameter("s_id");
                    String insert_quarter_begin = request.getParameter("quarter_begin");
					String insert_quarter_end = request.getParameter("quarter_end");
					
					if(insert_s_id.equals("def") || insert_quarter_begin.equals("") || insert_quarter_end.equals("")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_s_id.equals("def")){
                        %> 
                            <%= "Please select the Student ID<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_quarter_begin.equals("")){
                        %>
                            <%= "Please enter a quarter and year<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_quarter_end.equals("")){
                        %>
                            <%= "Please enter a quarter and year<br />" %>
                        </ br>
                        <%
                        }
                    }
				}
				else{
					
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT student values INTO the students table.
                    pstmt = conn
                    .prepareStatement("INSERT INTO attendance (s_id, quarter_begin, quarter_end) VALUES (?, ?, ?)");

                    
					pstmt.setInt(1, Integer.parseInt(request.getParameter("s_id")));
					pstmt.setString(2, request.getParameter("quarter_begin"));
					pstmt.setString(3, request.getParameter("quarter_end"));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
				// Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM attendance");
                rs = pstmt.executeQuery();

                // Retrieve the college
                ArrayList<String> student_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM students");
                rs1 = pstmt.executeQuery();
                while(rs1.next()){
                    student_list.add(rs1.getString("s_id"));
                }

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
				
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
				<th>Student ID</th>
				<th>From Quarter, Year</th>
				<th>To Quarter, Year</th>
				
            </tr>

            <tr>
                <form action="attendance.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
					
					<th>
                        <select name="s_id">
                        <option value="def">Student ID</option>
                        <%
                        for(String s: student_list){
                        %>
                            <option value="<%= s %>"><%= s %></option>
                        <%  
                        }
                        %>
                        </select>
                    </th>
					
					<th><input value="" name="quarter_begin" size="10"/></th>
					<th><input value=" " name="quarter_end" size="10"/></th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
				<%-- Get the sid --%>
                <td>
                    <%= rs.getInt("s_id") %>
                </td>
				
				<%-- Get the from year and quarter --%>
                <td>
                    <%= rs.getString("quarter_begin") %>
                </td>
				
				<%-- Get the to year and quarter --%>
                <td>
                    <%= rs.getString("quarter_end") %>
                </td>
            </tr>

            <%
                }
            %>

            <%-- -------- Close Connection Code -------- --%>
            <%
                // Close the ResultSet
                rs.close();
				rs1.close();

               

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

