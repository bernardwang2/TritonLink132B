<html>
<HEAD><TITLE>CSE132B Webapp: Thesis Committee</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Thesis Committee</FONT> <P />



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
            <%@ page import="java.util.*"%>
            <%@ page import="java.util.ArrayList"%>
            <%@ page import="java.util.List"%>

            <%-- -------- Open Connection Code -------- --%>
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
			ResultSet rs1 = null;
			ResultSet rs2 = null;
            
            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
				String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(dbURL);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
					String insert_s_id= request.getParameter("s_id");
					String insert_committee_id = request.getParameter("committee_id");
					String insert_professor_one = request.getParameter("professor_one");
					String insert_professor_two = request.getParameter("professor_two");
					String insert_professor_three = request.getParameter("professor_three");



                    pstmt = conn.prepareStatement("SELECT * FROM graduates WHERE s_id = ?"); 
                    pstmt.setInt(1, Integer.parseInt(insert_s_id));
                    rs2 = pstmt.executeQuery();
                    rs2.next();
                    String ms_or_phd = rs2.getString("ms_or_phd");
                    


                    Set<String> department_set = new HashSet<String>();
                    pstmt = conn.prepareStatement("SELECT * FROM faculty WHERE faculty_name = ?");
                    pstmt.setString(1, insert_professor_one);
                    rs2 = pstmt.executeQuery();
                    rs2.next();
                    String prof_department = rs2.getString("faculty_department");
                    department_set.add(prof_department);
                    
                    pstmt = conn.prepareStatement("SELECT * FROM faculty WHERE faculty_name = ?");
                    pstmt.setString(1, insert_professor_two);
                    rs2 = pstmt.executeQuery();
                    rs2.next();
                    prof_department = rs2.getString("faculty_department");
                    department_set.add(prof_department);
                    
                    pstmt = conn.prepareStatement("SELECT * FROM faculty WHERE faculty_name = ?");
                    pstmt.setString(1, insert_professor_three);
                    rs2 = pstmt.executeQuery();
                    rs2.next();
                    prof_department = rs2.getString("faculty_department");
                    department_set.add(prof_department);


					
                    if(insert_s_id.equals("def") || insert_committee_id.equals("") || insert_professor_one.equals("def") ||
                       insert_professor_two.equals("def") || insert_professor_three.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_s_id.equals("def")){
                        %>
                            <%= "Please select sid<br />" %>
                        </ br>
                        <%
                        }
						if(insert_committee_id.equals("")){
                        %>
                            <%= "Please insert the committee id<br />" %>
                        </ br>
                        <%
                        }
						if(insert_professor_one.equals("")){
                        %>
                            <%= "Please insert a professor<br />" %>
                        </ br>
                        <%
                        }
						if(insert_professor_two.equals("")){
                        %>
                            <%= "Please insert a professor<br />" %>
                        </ br>
                        <%
                        }
						if(insert_professor_three.equals("")){
                        %>
                            <%= "Please insert a professor<br />" %>
                        </ br>
                        <%
                        }
                    }
                    else if(insert_professor_one.equals(insert_professor_two) || insert_professor_two.equals(insert_professor_three) ||
                            insert_professor_one.equals(insert_professor_three)){
                        %>
                            <%= "Data Insertion Failure: professors cannot be repeated<br />" %>
                        </ br>
                        <%
                    }
                    else if(ms_or_phd.equals("PhD") && department_set.size() < 2){
                        %>
                            <%= "Data Insertion Failure: at least one professor has to belong to another department<br />" %>
                        </ br>
                        <%
                    }
					else{
						conn.commit();
						conn.setAutoCommit(true);
					
					
						// Begin transaction
						conn.setAutoCommit(false);

						// Create the prepared statement and use it to
						pstmt = conn.prepareStatement
                        ("INSERT INTO thesis_committee (s_id, committee_id, faculty_one, faculty_two, faculty_three)"
                        + "VALUES (?, ?, ?, ?, ?)");
				
						pstmt.setInt(1, Integer.parseInt(insert_s_id));
						pstmt.setInt(2, Integer.parseInt(insert_committee_id));
						pstmt.setString(3, insert_professor_one);
						pstmt.setString(4, insert_professor_two);
						pstmt.setString(5, insert_professor_three);
						int rowCount = pstmt.executeUpdate();

						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
					}
				}
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
			conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM thesis_committee");
                rs = pstmt.executeQuery();

                // Retrieve the sid
                ArrayList<String> s_id_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM graduates");
                rs1 = pstmt.executeQuery();
                while(rs1.next()){
                    s_id_list.add(rs1.getString("s_id"));
                }

				// Retrieve the professor
                ArrayList<String> professor_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM faculty");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    professor_list.add(rs2.getString("faculty_name"));
                }
				
				
				
                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Committee_ID</th>
				<th>Student ID</th>
				<th>Professor 1</th>
				<th>Professor 2</th>
				<th>Professor 3</th>
			</tr>
			
            <tr>
                <form action="thesis_committee.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="committee_id" size="15"/></th>
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
                        <select name="professor_one">
                        <option value="def">--SELECT ONE--</option>
                        <%
                        for(String s: professor_list){
                        %>
                            <option value="<%= s %>"><%= s %></option>
                        <%  
                        }
                        %>
                        </select>
                    </th>
					<th>
                        <select name="professor_two">
                        <option value="def">--SELECT ONE--</option>
                        <%
                        for(String s: professor_list){
                        %>
                            <option value="<%= s %>"><%= s %></option>
                        <%  
                        }
                        %>
                        </select>
                    </th>
					<th>
                        <select name="professor_three">
                        <option value="def">--SELECT ONE--</option>
                        <%
                        for(String s: professor_list){
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
                <%-- Get the committee id --%>
                <td>
                    <%= rs.getInt("committee_id") %>
                </td>

				<%-- Get the student id --%>
                <td>
                    <%= rs.getInt("s_id") %>
                </td>
				
				<%-- Get the professor 1 --%>
                <td>
                    <%= rs.getString("faculty_one") %>
                </td>
				
				<%-- Get the professor 2 --%>
                <td>
                    <%= rs.getString("faculty_two") %>
                </td>
				
				<%-- Get the professor 3 --%>
                <td>
                    <%= rs.getString("faculty_three") %>
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

