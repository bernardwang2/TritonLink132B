<html>
<HEAD><TITLE>CSE132B Webapp: Faculty Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Faculty Entry Form</FONT> <P />

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
                ArrayList<String> faculty_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM faculty");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    faculty_list.add(rs2.getString("faculty_name"));
                }
                // Get all options
                ArrayList<String> department_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM departments");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    department_list.add(rs2.getString("d_name"));
                }
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    String insert_faculty_name = request.getParameter("faculty_name");
                    String insert_faculty_title = request.getParameter("faculty_title");
                    String insert_faculty_department = request.getParameter("d_name");

                    if(insert_faculty_name.equals("") || insert_faculty_title.equals("def") || insert_faculty_department.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_faculty_name.equals("")){
                        %>
                            <%= "Please enter a faculty name<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_faculty_title.equals("def")){
                        %>
                            <%= "Please choose a faculty title<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_faculty_department.equals("def")){
                        %>
                            <%= "Please choose a department<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else {
                        // Begin transaction
                        conn.setAutoCommit(false);

                        pstmt = conn
                        .prepareStatement("INSERT INTO faculty (faculty_name, faculty_title, faculty_department) VALUES (?, ?, ?)");
                       
                        pstmt.setString(1, insert_faculty_name);
                        pstmt.setString(2, insert_faculty_title);
                        pstmt.setString(3, insert_faculty_department);
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
                .prepareStatement("SELECT * FROM faculty");
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Faculty Name</th>
                <th>Faculty Title</th>
                <th>Department</th>
            </tr>

            <tr>
                <form action="faculty.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="faculty_name" size="15"/></th>
                    <th>
                        <select name="faculty_title">
                            <option value="def">--SELECT ONE--</option>
                            <option value="Lecturer">Lecturer</option>
                            <option value="Assistant Professor">Assistant Professor</option>
                            <option value="Associate Professor">Associate Professor</option>
                            <option value="Professor">Professor</option>
                        </select>
                    </th>
                    <th>
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
				
				<%-- Get the faculty name --%>
                <td>
                    <%= rs.getString("faculty_name") %>
                </td>
				
				<%-- Get the title --%>
                <td>
                    <%= rs.getString("faculty_title") %>
                </td>
				
                <%-- Get the department --%>
                <td>
                    <%= rs.getString("faculty_department") %>
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

