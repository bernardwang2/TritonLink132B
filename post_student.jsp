<html>
<HEAD><TITLE>CSE132B Webapp: Student Entry Form</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Student Entry Form</FONT> <P />



<table>

    <!-- Show Home Button -->
    <tr>
        <td align="left">
            <form action="student.jsp" method="POST">
                <input type="submit" value="Student Entry Form"/>
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
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {
                    
                    String insert_first = request.getParameter("first_name");
                    String insert_middle = request.getParameter("middle_name");
                    String insert_last = request.getParameter("last_name");
                    String insert_s_id = request.getParameter("s_id");
                    String insert_ssn = request.getParameter("ssn");
                    String insert_ug = request.getParameter("u/g");
                    String insert_residency = request.getParameter("residency");
                    String insert_enrolled = request.getParameter("enrolled");
                    String insert_extra_degree = request.getParameter("extra_degree");

                    if(insert_first.equals("") || insert_last.equals("") || insert_s_id.equals("") || insert_ssn.equals("") ||
                       insert_ug.equals("def") || insert_residency.equals("def") || insert_enrolled.equals("def") ||
                       insert_extra_degree.equals("def")) {
                    %>
                        <%= "Data Insertion Failure:<br />" %>
                    <%
                        if(insert_first.equals("")){
                        %>
                            <%= "Please enter the first name<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_last.equals("")){
                        %>
                            <%= "Please enter the last name<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_s_id.equals("")){
                        %>
                            <%= "Please enter the student id<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_ssn.equals("")){
                        %>
                            <%= "Please enter the SSN<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_ug.equals("def")){
                        %>
                            <%= "Please choose the U/G<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_residency.equals("def")){
                        %>
                            <%= "Please chooose the residency<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_enrolled.equals("def")){
                        %>
                            <%= "Please choose a enrolled status<br />" %>
                        </ br>
                        <%
                        }
                        if(insert_extra_degree.equals("def")){
                        %>
                            <%= "Please choose an extra degree<br />" %>
                            </ br>
                        <%
                        }
                    }
                    else if(insert_ssn.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Course ID must consists of numbers" %>
                    <%
                    }
                    else if(insert_s_id.matches("[0-9]+") == false){
                    %>
                        <%= "Data Insertion Failure: Course Units must consists of numbers" %>
                    <%
                    }
                    else{
                        int insert_s_id_num = Integer.parseInt(insert_s_id);
                        int insert_ssn_num = Integer.parseInt(insert_ssn);
                        if(insert_s_id_num < 10000 || insert_s_id_num > 99999){
                        %>
                            <%= "Data Insertion Failure: Course ID must be a 3-digit number" %>
                        <%
                        }
                        else if(insert_ssn_num < 100000000 || insert_ssn_num > 999999999){
                        %>
                            <%= "Data Insertion Failure: SSN must be a 9-digit number" %>
                        <%
                        }
                        else{
                            // Begin transaction
                            conn.setAutoCommit(false);

                            pstmt = conn
                            .prepareStatement
                            ("INSERT INTO students (s_id, first_name, middle_name, last_name, ssn, residency, enrolled, extra_degree)" + 
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                   
                            pstmt.setInt(1, insert_s_id_num);
                            pstmt.setString(2, insert_first);
                            pstmt.setString(3, insert_middle);
                            pstmt.setString(4, insert_last);
                            pstmt.setInt(5, insert_ssn_num);
                            pstmt.setString(6, insert_residency);
                            pstmt.setString(7, insert_enrolled);
                            pstmt.setString(8, insert_extra_degree);
                            int rowCount = pstmt.executeUpdate();

                            // Graduate
                            if(insert_ug.equals("Undergraduate")){
                                String insert_college = request.getParameter("college");
                                String insert_major = request.getParameter("major");
                                String insert_minor = request.getParameter("minor");
                                String insert_ms_program = request.getParameter("ms_program");

                                pstmt = conn.prepareStatement
                                ("INSERT INTO undergraduates (s_id, college, major, minor, ms_program) VALUES (?, ?, ?, ?, ?)");
                                pstmt.setInt(1, insert_s_id_num);
                                pstmt.setString(2, insert_college);
                                pstmt.setString(3, insert_major);
                                pstmt.setString(4, insert_minor);
                                pstmt.setString(5, insert_ms_program);

                                pstmt.executeUpdate();
                            }
                            else if (insert_ug.equals("Graduate")){
                                String insert_department = request.getParameter("d_name");
                                String insert_ms_phd = request.getParameter("ms_phd");
                                String insert_phd_candidacy = request.getParameter("phd_candidacy");

                                pstmt = conn.prepareStatement
                                ("INSERT INTO graduates (s_id, d_name, ms_or_phd, candidacy) VALUES (?, ?, ?, ?)");
                                pstmt.setInt(1, insert_s_id_num);
                                pstmt.setString(2, insert_department);
                                pstmt.setString(3, insert_ms_phd);
                                pstmt.setString(4, insert_phd_candidacy);

                                pstmt.executeUpdate();
                            }
                            // Commit transaction
                            conn.commit();
                            conn.setAutoCommit(true);

                            %>
                            <%= "Student Succesfully Added" %>
                            <%
                        }
                    }
                }
            %>

            <%-- -------- Close Connection Code -------- --%>
            <%
                // Close the ResultSet
                //rs.close();

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

