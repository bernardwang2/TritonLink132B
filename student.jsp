<html>
<HEAD><TITLE>CSE132B Webapp: Student Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Student Entry Form</FONT> <P />



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
            <p>Note: Student ID must be a 5 digit number</p>
        </td>
    </tr>


    <form action="post_student.jsp" method="POST">
    <input type="hidden" name="action" value="insert"/>
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
                conn = DriverManager.getConnection(
                    dbURL);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
				// Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM students ORDER BY s_id");
                rs = pstmt.executeQuery();

                // Retrieve the college
                ArrayList<String> college_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM colleges");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    college_list.add(rs2.getString("college"));
                }

                // Retrieve the departments
                ArrayList<String> department_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM departments");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    department_list.add(rs2.getString("d_name"));
                }

                // Retrieve the majors
                ArrayList<String> major_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM degrees");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    major_list.add(rs2.getString("degree_name"));
                }

                // Retrieve the minor
                ArrayList<String> minor_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM minors");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    minor_list.add(rs2.getString("minor"));
                }

                // Retrieve the extra degrees
                ArrayList<String> extra_degree_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM extra_degrees");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    extra_degree_list.add(rs2.getString("degree_name"));
                }

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
				
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>First Name</th>
                <th>Middle Name (o)</th>
                <th>Last Name</th>
                <th>Student ID</th>
				<th>SSN</th>
                <th>U/G</th>
				<th>Residency</th>
				<th>Currently Enrolled</th>
				<th>Received Degree (o)</th>
            </tr>

            <tr>
                <!-- <form action="post_student.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/> -->
                    <th><input value="" name="first_name" size="20"/></th>
                    <th><input value="" name="middle_name" size="20"/></th>
                    <th><input value="" name="last_name" size="20"/></th>
                    <th><input value="" name="s_id" size="15"/></th>
					<th><input value="" name="ssn" size="15"/></th>
                    <th>
                        <select name="u/g">
                        <option value="def">--SELECT ONE--</option>
                        <option value="Graduate">Graduate</option>
                        <option value="Undergraduate">Undergraduate</option>
                        </select>
                    </th>
                    <th>
                        <select name="residency">
                        <option value="def">--SELECT ONE--</option>
                        <option value="California Resident">California Resident</option>
                        <option value="Foreign Student">Foreign Student</option>
                        <option value="Non-CA US. Student">Non-CA US. Student</option>
                        </select>
                    </th>
                    <th>
                        <select name="enrolled">
                        <option value="def">--SELECT ONE--</option>
                        <option value="Yes">Yes</option>
                        <option value="No">No</option>
                        </select>
                    </th>
					<th>
                        <select name="extra_degree">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: extra_degree_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
					<!-- <th><input type="submit" value="Insert"/></th> -->
                <!-- </form> -->
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>	
				<%-- Get the first name --%>
                <td>
                    <%= rs.getString("first_name") %>
                </td>
				
				<%-- Get the middle name --%>
                <td>
                    <%= rs.getString("middle_name") %>
                </td>
				
				<%-- Get the last name --%>
                <td>
                    <%= rs.getString("last_name") %>
                </td>
				
                <%-- Get the s_id --%>
                <td>
                    <%= rs.getInt("s_id") %>
                </td>

                <%-- Get the ssn --%>
                <td>
                    <%= rs.getInt("ssn") %>
                </td>

                <td></td>

                <%-- Get the residency --%>
                <td>
                    <%= rs.getString("residency") %>
                </td>
				
				<%-- Get the enrolled --%>
                <td>
                    <%= rs.getString("enrolled") %>
                </td>
				
				<%-- Get the extra degree --%>
                <td>
                    <%= rs.getString("extra_degree") %>
                </td>
            </tr>

            <%
                }
            %>
        </table>
        </td>
    </tr>


    <!-- Empty Row -->
    <tr>
        <td>
            <p></p>
        </td>
    </tr>

    <!-- Undergraduate Form -->
    <tr>
        <td>
            <p>For Undergraduates:</p>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>College</th>
                    <th>Major</th>
                    <th>Minor</th>
                    <th>MS Program</th>
                </tr>
                <tr>
                    <td>
                        <select name="college">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: college_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </td>
                    <td>
                        <select name="major">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: major_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </td>
                    <td>
                        <select name="minor">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: minor_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </td>
                    <td>
                        <select name="ms_program">
                            <option value="def">--SELECT ONE--</option>
                            <option value="Yes">Yes</option>
                            <option value="No">No</option>
                        </select>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <!-- Empty Row -->
    <tr>
        <td>
            <p>For Graduates:</p>
        </td>
    </tr>

    <!-- Graduate Form -->
    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Department</th>
                    <th>MS/PhD</th>
                </tr>
                <tr>
                    <td>
                        <select name="d_name">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: department_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </td>
                    <td>
                        <select name="ms_phd">
                            <option value="def">--SELECT ONE--</option>
                            <option value="PhD">PhD</option>
                            <option value="MS">MS</option>
                        </select>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <!-- Empty Row -->
    <tr>
        <td>
            <p>For PhD:</p>
        </td>
    </tr>

    <!-- PhD Form -->
    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>PhD Candidacy</th>
                </tr>
                <tr>
                    <td>
                        <select name="phd_candidacy">
                            <option value="def">--SELECT ONE--</option>
                            <option value="PhD Candidate">PhD Candidate</option>
                            <option value="Pre-Candidate">Pre-Candidate</option>
                        </select>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <tr>
        <td>
            <p></p>
        </td>
    </tr>

    <tr>
        <td>
            <input type="submit" value="Submit"/>
        </td>
    </tr>
    </form>



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

