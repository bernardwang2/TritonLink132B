<html>
<HEAD><TITLE>CSE132B Webapp: Course Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Course Entry Form</FONT> <P />

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
            ResultSet rs3 = null;


            
            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
				String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
                conn = DriverManager.getConnection(dbURL);



                // Begin transaction
                conn.setAutoCommit(false);

                // Get all c_id
                ArrayList<Integer> cid_list = new ArrayList<Integer>();
                ArrayList<String> course_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM courses");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    cid_list.add(Integer.valueOf(rs2.getInt("c_id")));
                    course_list.add(rs2.getString("c_name"));
                }

                // Retrieve the departments
                ArrayList<String> department_list = new ArrayList<String>();
                pstmt = conn.prepareStatement("SELECT * FROM departments");
                rs2 = pstmt.executeQuery();
                while(rs2.next()){
                    department_list.add(rs2.getString("d_name"));
                }

                // Setup unit range
                ArrayList<String> units_range = new ArrayList<String>();
                for(int i = 1; i < 9; i++){
                    units_range.add(Integer.toString(i));
                }

                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    String insert_c_id = request.getParameter("c_id");
                    String insert_c_name = request.getParameter("c_name");
                    String insert_d_name = request.getParameter("d_name");
                    String insert_c_urange = request.getParameter("c_urange");
                    String insert_grading_option = request.getParameter("grading_option");
                    String insert_instructor_consent = request.getParameter("instructor_consent");
                    String insert_lab_work = request.getParameter("lab_work");

                    if(insert_c_id.equals("") || insert_c_name.equals("") || insert_d_name.equals("def") || insert_c_urange.equals("def") ||
                       insert_grading_option.equals("def") || insert_lab_work.equals("def") || insert_instructor_consent.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_c_id.equals("")){
                        %>
                            <%= "Please enter a course id<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_c_name.equals("")){
                        %>
                            <%= "Please enter a course name<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_d_name.equals("def")){
                        %>
                            <%= "Please choose a department<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_c_urange.equals("def")){
                        %>
                            <%= "Please choose a unit range<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_grading_option.equals("def")){
                        %>
                            <%= "Please choose a grading option<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_lab_work.equals("def")){
                        %>
                            <%= "Please specify whether a laboratory work is required<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_instructor_consent.equals("def")){
                        %>
                            <%= "Please specify whether an instructor's consent is required<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else if(insert_c_id.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Course ID must consists of numbers only<br />" %>
                        </ br>
                    <%
                    }
                    else if(cid_list.contains(Integer.valueOf(insert_c_id))){
                    %>
                        <%= "Data Insertion Failure: Please enter an unique course id<br />" %>
                        </ br>
                    <%
                    }
                    else if(course_list.contains(insert_c_name)){
                    %>
                        <%= "Data Insertion Failure: Please enter an unique course name<br />" %>
                        </ br>
                    <%
                    }
                    else{
                        // Begin transaction
                        conn.setAutoCommit(false);

                        // Insert into courses table
                        course_list.add(insert_c_name);
                        pstmt = conn.
                        prepareStatement
                        ("INSERT INTO courses (c_id, c_name, d_name, c_unit_range, grading_option, lab_work, instructor_consent)" +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)");
                        pstmt.setInt(1, Integer.parseInt(insert_c_id));
                        pstmt.setString(2, insert_c_name);
                        pstmt.setString(3, insert_d_name);
                        pstmt.setInt(4, Integer.parseInt(insert_c_urange));
                        pstmt.setString(5, insert_grading_option);
                        pstmt.setString(6, insert_lab_work);
                        pstmt.setString(7, insert_instructor_consent);
                        int rowCount = pstmt.executeUpdate();

                        // Commit transaction
                        conn.commit();
                        conn.setAutoCommit(true);
                    }
                }
                else if(action != null && action.equals("add")) {
                    String insert_c_name = request.getParameter("c_name");
                    String insert_pre_req_name = request.getParameter("pre_req_name");
                    if(insert_c_name.equals("def") || insert_pre_req_name.equals("def")){
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_c_name.equals("def")){
                        %>
                            <%= "Please choose a course<br />" %>
                            </ br>
                        <%
                        }
                        if(insert_pre_req_name.equals("def")){
                        %>
                            <%= "Please choose a prerequisite course<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else if(insert_c_name.equals(insert_pre_req_name)){
                    %>
                        <%= "Data Insertion Failure: a course cannot be a prerequisite of itself<br />" %>
                        </ br>
                    <%
                    }
                    else{
                        // Begin transaction
                        conn.setAutoCommit(false);

                        pstmt = conn.
                        prepareStatement
                        ("INSERT INTO prerequisites (c_name, pre_cname) VALUES (?, ?)");
                        pstmt.setString(1, insert_c_name);
                        pstmt.setString(2, insert_pre_req_name);
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

                pstmt = conn.prepareStatement("SELECT * FROM courses");
                rs = pstmt.executeQuery();

                pstmt = conn.prepareStatement("SELECT * FROM prerequisites");
                rs3 = pstmt.executeQuery();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Course ID</th>
                <th>Course Name</th>
                <th>Department</th>
                <th>Max Units</th>
                <th>Grading Option</th>
                <th>Laboratory Work</th>
                <th>Instructor Consent</th>
            </tr>

            <tr>
                <form action="course.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th><input value="" name="c_id" size="15"/></th>
                    <th><input value="" name="c_name" size="15"/></th>
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
                    <th>
                        <select name="c_urange">
                        <option value="def">--SELECT ONE--</option>
                        <%
                        for(String s: units_range){
                        %>
                            <option value="<%= s %>"><%= s %></option>
                        <%  
                        }
                        %>
                        </select>
                    </th>
                    <th>
                        <select name="grading_option">
                        <option value="def">--SELECT ONE--</option>
                        <option value="Letter Grade Only">Letter Grade Only</option>
                        <option value="S/U Only">S/U Only</option>
                        <option value="Letter Grade or S/U">Letter Grade or S/U</option>
                        </select>
                    </th>
                    <th>
                        <select name="lab_work">
                        <option value="def">--SELECT ONE--</option>
                        <option value="Yes">Yes</option>
                        <option value="No">No</option>
                        </select>
                    </th>
                    <th>
                        <select name="instructor_consent">
                        <option value="def">--SELECT ONE--</option>
                        <option value="Required">Required</option>
                        <option value="Not Required">Not Required</option>
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
                <%-- Get the course id --%>
                <td>
                    <%= rs.getInt("c_id") %>
                </td>

                <%-- Get the course name --%>
                <td>
                    <%= rs.getString("c_name") %>
                </td>

                <%-- Get the department id --%>
                <td>
                    <%= rs.getString("d_name") %>
                </td>

                <%-- Get the course units --%>
                <td>
                    <%= rs.getInt("c_unit_range") %>
                </td>

                <%-- Get the grading option --%>
                <td>
                    <%= rs.getString("grading_option") %>
                </td>

                <%-- Get the lab work --%>
                <td>
                    <%= rs.getString("lab_work") %>
                </td>

                <%-- Get the instructor consent --%>
                <td>
                    <%= rs.getString("instructor_consent") %>
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

    <!-- Empty Row -->
    <tr>
        <td>
            <p>Add a Prerequisite:</p>
        </td>
    </tr>

    <tr>
        <td>
        <table border="1">
            <tr>
                <th>Course</th>
                <th>Prerequisite</th>
            </tr>
            <tr>
                <form action="course.jsp" method="POST">
                    <input type="hidden" name="action" value="add"/>
                    <th>
                        <select name="c_name">
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
                    <th>
                        <select name="pre_req_name">
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
                    <th><input type="submit" value="Add"/></th>
                </form>
            </tr>

            <%
                // Iterate over the ResultSet
                while (rs3.next()) {
            %>

            <tr>
                <%-- Get the course id --%>
                <td>
                    <%= rs3.getString("c_name") %>
                </td>

                <%-- Get the course name --%>
                <td>
                    <%= rs3.getString("pre_cname") %>
                </td>
            </tr>
            <%
                }
            %>
        </table>
        </td>
    </tr>

    <%-- -------- Close Connection Code -------- --%>
    <%
        // Close the ResultSet
        rs.close();
        rs2.close();
        rs3.close();

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

