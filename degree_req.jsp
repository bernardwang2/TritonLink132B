<html>
<HEAD><TITLE>CSE132B Webapp: Degree Requirements Info Submission</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Degree Requirements Info Submission</FONT> <P />

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

                    String insert_degree_name = request.getParameter("degree_name");
                    String insert_d_name = request.getParameter("d_name");
                    String insert_total_units = request.getParameter("total_units");

                    if(insert_degree_name.equals("") || insert_d_name.equals("def") || insert_total_units.equals("")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_degree_name.equals("")){
                        %>
                            <%= "Please enter a degree name<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_d_name.equals("def")){
                        %>
                            <%= "Please choose a department<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_total_units.equals("")){
                        %>
                            <%= "Please enter required units<br />" %>
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
                        ("INSERT INTO degrees (degree_name, d_name, total_units) VALUES (?, ?, ?)");

                        pstmt.setString(1, insert_degree_name);
                        pstmt.setString(2, insert_d_name);
                        pstmt.setInt(3, Integer.parseInt(insert_total_units));
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
                pstmt = conn.prepareStatement("SELECT * FROM degrees");
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Degree Name</th>
                <th>Department</th>
                <th>Required Units</th>
            </tr>

            <tr>
                <form action="degree_req.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input name="degree_name" value="" size="100"/></th>
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
                    <th><input name="total_units" value=""/></th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
                <%-- Get the name --%>
                <td>
                    <%= rs.getString("degree_name") %>
                </td>
                
                <%-- Get the department --%>
                <td>
                    <%= rs.getString("d_name") %>
                </td>
                
                <%-- Get the total units --%>
                <td>
                    <%= rs.getInt("total_units") %>
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

