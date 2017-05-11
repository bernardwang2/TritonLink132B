<html>

<HEAD><TITLE>CSE132B Webapp: College</TITLE></HEAD>
<BODY>  <FONT SIZE="5">College</FONT> <P />


<table>
    <tr>
        <td>
            <%-- Import the java.sql package --%>
            <%@ page import="java.sql.*"%>
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
                conn = DriverManager.getConnection(
                    dbURL);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
					String insert_college_name = request.getParameter("college_name");
					
					if(insert_college_name.equals("")){
                        %>
                            <%= "Please enter the College Name<br />" %>
                        </ br>
                        <%
                    }
					else{
						// Begin transaction
						conn.setAutoCommit(false);

						// Create the prepared statement and use it to
						pstmt = conn
						.prepareStatement("INSERT INTO college (college_name) VALUES (?)");

                    
					
						pstmt.setString(1, request.getParameter("college_name"));
						int rowCount = pstmt.executeUpdate();

						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
					}
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Create the statement
                Statement statement = conn.createStatement();

                // Use the created statement to SELECT
                rs = statement.executeQuery("SELECT * FROM college");
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
				<th>College Name</th>
            </tr>

            <tr>
                <form action="college.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="college_name" size="10"/></th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
				<%-- Get the college name --%>
                <td>
                    <%= rs.getString("college_name") %>
                </td>
				
            </tr>

            <%
                }
            %>

            <%-- -------- Close Connection Code -------- --%>
            <%
                // Close the ResultSet
                rs.close();

                // Close the Statement
                statement.close();

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

