<html>
<HEAD><TITLE>CSE132B Webapp: Class Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Class Entry Form</FONT> <P />

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
                ArrayList<Integer> class_id_list = new ArrayList<Integer>();
                ArrayList<String> year_list = new ArrayList<String>();
                ArrayList<String> quarter_list = new ArrayList<String>();
                ArrayList<String> course_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM classes");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    class_id_list.add(Integer.valueOf(rs2.getInt("class_id")));
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
                pstmt = conn.prepareStatement("SELECT * FROM courses");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    course_list.add(rs2.getString("c_name"));
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
                    String insert_class_name = request.getParameter("class_name");
                    String insert_class_title = request.getParameter("class_title");
                    String insert_class_year = request.getParameter("class_year");
                    String insert_class_quarter = request.getParameter("class_quarter");

                    if(insert_class_id.equals("") || insert_class_name.equals("def") || insert_class_title.equals("") ||
                       insert_class_year.equals("def") || insert_class_quarter.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_class_id.equals("")){
                        %>
                            <%= "Please enter a class id<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_class_name.equals("def")){
                        %>
                            <%= "Please choose a corresponding course name<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_class_title.equals("")){
                        %>
                            <%= "Please enter a class title<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_class_year.equals("def")){
                        %>
                            <%= "Please choose a year<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_class_quarter.equals("def")){
                        %>
                            <%= "Please choose a quarter<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else if(insert_class_id.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Class ID must consists of numbers only<br />" %>
                        </ br>
                    <%
                    }
                    else if(class_id_list.contains(Integer.valueOf(insert_class_id))){
                    %>
                        <%= "Data Insertion Failure: Please enter an unique class id<br />" %>
                        </ br>
                    <%
                    }
                    else{
                        pstmt = conn.prepareStatement("SELECT * FROM classes WHERE class_name = ? AND class_year = ? AND class_quarter = ?");
                        pstmt.setString(1, insert_class_name);
                        pstmt.setInt(2, Integer.parseInt(insert_class_year));
                        pstmt.setString(3, insert_class_quarter);
                        rs2 = pstmt.executeQuery();
                        if(rs2.next()){
                        %>
                            <%= "Data Insertion Failure: this class already exists<br />" %>
                            </ br>
                        <%
                        }
                        else{
                            // Begin transaction
                            conn.setAutoCommit(false);

                            pstmt = conn
                            .prepareStatement(
                            "INSERT INTO classes (class_id, class_name, class_title, class_year, class_quarter)" +
                            "VALUES (?, ?, ?, ?, ?)");

                            pstmt.setInt(1, Integer.parseInt(insert_class_id));
                            pstmt.setString(2, insert_class_name);
                            pstmt.setString(3, insert_class_title);
                            pstmt.setInt(4, Integer.parseInt(insert_class_year));
                            pstmt.setString(5, insert_class_quarter);
                            int rowCount = pstmt.executeUpdate();

                            // Commit transaction
                            conn.commit();
                            conn.setAutoCommit(true);
                        }
                    }
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("SELECT * FROM classes ORDER BY class_year ASC, class_quarter DESC, class_name ASC");
                rs = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Class ID</th>
                <th>Class Name</th>
                <th>Title</th>
                <th>Year</th>
				<th>Quarter</th>
            </tr>

            <tr>
                <form action="class.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="class_id" size="15"/></th>
                    <th>
                        <select name="class_name">
                            <option value="def">--SELECT ONE--</option>
                            <%
                            for(String s: course_list){
                            %>
                                <option value="<%= s %>"><%= s %></option>
                            <%  
                            }
                            %>
                        </select>
                    </th>
                    <th><input value="" name="class_title" size="15"/></th>
                    <th>
                        <select name="class_year">
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
                        <select name="class_quarter">
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
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
                <form action="sections.jsp" method="POST">
                    <input type="hidden" name="action" value="add_section"/>
                    <input type="hidden" name="class_id" value="<%=rs.getInt("class_id")%>"/>
                    <input type="hidden" name="class_name" value="<%=rs.getString("class_name")%>"/>
                <%-- Get the course id --%>
                <td>
                    <%= rs.getInt("class_id") %>
                </td>

                <%-- Get the name --%>
                <td>
                    <%= rs.getString("class_name") %>
                </td>

                <%-- Get the title --%>
                <td>
                    <%= rs.getString("class_title") %>
                </td>
				
				<%-- Get the year --%>
                <td>
                    <%= rs.getInt("class_year") %>
                </td>
				
				<%-- Get the quarter --%>
                <td>
                    <%= rs.getString("class_quarter") %>
                </td>
                <td>
                    <input type="submit" value="Add Sections">
                </td>
                </form>
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

