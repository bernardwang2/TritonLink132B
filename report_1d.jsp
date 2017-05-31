<html>
<HEAD><TITLE>CSE132B Webapp: Report 1d</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 1d</FONT> <P />



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

    // Retrieve all undergraduates
    pstmt = conn.prepareStatement("SELECT s.ssn, s.first_name, s.last_name " +
                                  "FROM students s " +
                                  "WHERE s.s_id IN " +
                                  " (SELECT u.s_id" +
                                  "  FROM undergraduates u) " +
                                  "ORDER BY s.ssn");
    rs = pstmt.executeQuery();

    // Retrieve all bachelor degrees
    pstmt = conn.prepareStatement("SELECT d.degree_name " +
                                  "FROM degrees d " +
                                  "WHERE d.degree_type != 'M.S'");
    rs2 = pstmt.executeQuery();
%>



<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="home.jsp" method="GET">
                <input type="submit" value="Home"/>
            </form>
        </td>
    </tr>

    <!-- User Prompt -->
    <tr>
        <td>
            <table>
                <form action="report_1d.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the remaining degree requirements for bachelor:</p>
                </td>

                <td>
                    <select name="selected_student">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs.next()){
                %>
                        <option value="<%= rs.getInt("ssn") %>"><%= rs.getInt("ssn") +" "+rs.getString("first_name")+" "+rs.getString("last_name") %></option>
                <%
                    }
                %>
                    </select>
                </td>

                <td>
                    <p>in degree:</p>
                </td>

                <td>
                    <select name="selected_degree">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs2.next()){
                %>
                        <option value="<%= rs2.getString("degree_name") %>"><%= rs2.getString("degree_name") %></option>
                <%
                    }
                %>
                    </select>
                </td>
                
                <td>
                    <input type="submit" value="Submit"/>
                </td>
            
                </form>
            </table>
        </td>
    </tr>



    <!-- Display Results -->
<%
    String action = request.getParameter("action");
    if (action != null && action.equals("submit")) {

        // Get the student name and s_id
        String selected_ssn = request.getParameter("selected_student");
        pstmt = conn.prepareStatement("SELECT * FROM students WHERE ssn = ?");
        pstmt.setInt(1, Integer.parseInt(selected_ssn));
        rs = pstmt.executeQuery();
        rs.next();

        int selected_sid = rs.getInt("s_id");
        String selected_name = rs.getString("first_name") + " " + rs.getString("last_name");

        // Get all degree info
        String selected_degree = request.getParameter("selected_degree");
        pstmt = conn.prepareStatement("SELECT * FROM degrees WHERE degree_name = ?");
        pstmt.setString(1, selected_degree);
        rs = pstmt.executeQuery();
        rs.next();

        String bachelor_department = rs.getString("d_name");
        int total_units = rs.getInt("total_units");
        int lower_division_units = rs.getInt("lower_division_units");
        int upper_division_units = rs.getInt("upper_division_units");
        int tech_elective_units = rs.getInt("tech_elective_units");
        int grad_units_in_major = rs.getInt("grad_units_in_major");

        // Get electives
        pstmt = conn.prepareStatement("SELECT * FROM technical_electives");
        rs = pstmt.executeQuery();
        ArrayList<String> tech_elec_list = new ArrayList<String>();
        while(rs.next()){
            tech_elec_list.add(rs.getString("course_name"));
        }

        // Get student's history
        pstmt = conn.prepareStatement("SELECT c.class_name, r.units, co.d_name " +
                                      "FROM academic_history_new r, classes c, courses co " +
                                      "WHERE r.s_id = ? AND r.class_id = c.class_id AND c.class_name = co.c_name");
        pstmt.setInt(1, selected_sid);
        rs = pstmt.executeQuery();

        int total_units_taken = 0;
        int lower_division_taken = 0;
        int upper_division_taken = 0;
        int tech_elective_taken = 0;
        int grad_units_taken = 0;

        while(rs.next()){
            int course_units = rs.getInt("units");
            String course_name = rs.getString("class_name");
            int course_num = Integer.parseInt(course_name.replaceAll("[^0-9]", ""));
            String course_department = rs.getString("d_name");

            if(bachelor_department.equals(course_department)){
                if(course_num >= 200){
                    grad_units_taken = grad_units_taken + course_units;
                }
                else if(course_num >= 100){
                    upper_division_taken = upper_division_taken + course_units;
                }
                else{
                    lower_division_taken = lower_division_taken + course_units;
                }

                if(tech_elec_list.contains(course_name)){
                    tech_elective_taken = tech_elective_taken + course_units;
                }

                total_units_taken = total_units_taken + course_units;
            }
            else{
                if(tech_elec_list.contains(course_name)){
                    if (tech_elective_units > 0) {
                        tech_elective_taken = tech_elective_taken + course_units;
                        total_units_taken = total_units_taken + course_units;
                    }
                }
            }
        }

        int total_units_left = total_units - total_units_taken;
        int lower_division_left = lower_division_units - lower_division_taken;
        int upper_division_left = upper_division_units - upper_division_taken;
        int tech_elective_left = tech_elective_units - tech_elective_taken;
        int grad_units_left = grad_units_in_major - grad_units_taken;
%>

<%
        if(total_units_left > 0){
%>
    <tr>
        <td>
            <%= selected_name %> still need <%= total_units_left %> units in total to receive <%= selected_degree %>
        </td>
    </tr>

<%
            if(lower_division_left > 0){
%>
    <tr>
        <td>
            <%= selected_name %> still need <%= lower_division_left %> lower division units
        </td>
    </tr>
<%
            }
            if(upper_division_left > 0){
%>
    <tr>
        <td>
            <%= selected_name %> still need <%= upper_division_left %> upper division units
        </td>
    </tr>
<%
            }
            if(tech_elective_left > 0){
%>
    <tr>
        <td>
            <%= selected_name %> still need <%= tech_elective_left %> technical elective units
        </td>
    </tr>
<%
            }
            if(grad_units_left > 0){
%>
    <tr>
        <td>
            <%= selected_name %> still need <%= grad_units_left %> grad units
        </td>
    </tr>
<%
            }
        }
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
</body>

</html>

