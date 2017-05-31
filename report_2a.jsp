<html>
<HEAD><TITLE>CSE132B Webapp: Report 2a</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 2a</FONT> <P />



<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>

<%-- -------- Open Connection Code -------- --%>
<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
int current_year = 2017;
String current_quarter = "Spring";

try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    String dbURL = "jdbc:postgresql:cse132b?user=postgres&password=admin";
    conn = DriverManager.getConnection(dbURL);

    // Begin transaction
    conn.setAutoCommit(false);
    pstmt = conn.prepareStatement("SELECT DISTINCT s.ssn, s.first_name, s.last_name " +
                                  "FROM students s, academic_history_new r " +
                                  "WHERE s.s_id = r.s_id AND r.grade = 'IN' " +
                                  "ORDER BY s.ssn");
    rs = pstmt.executeQuery();

    conn.commit();
    conn.setAutoCommit(true);
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
                <form action="report_2a.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Display the class that student can not take</p>
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
                    <input type="submit" value="Submit"/>
                </td>
            
                </form>
            </table>
        </td>
    </tr>

    <!-- Display Results -->
<%
    String action = request.getParameter("action");
    // Check if an insertion is requested
    if (action != null && action.equals("submit")) {
		
		String selected_ssn = request.getParameter("selected_student");
        pstmt = conn.prepareStatement("SELECT * FROM students WHERE ssn = ?");
        pstmt.setInt(1, Integer.parseInt(selected_ssn));
        rs = pstmt.executeQuery();
        rs.next();
        String selected_name = rs.getString("first_name") + " " + rs.getString("last_name");
		
		String selected_student = request.getParameter("selected_student");
		
		ArrayList<String> class_list = new ArrayList<String>();
		ArrayList<String> class_list_course1 = new ArrayList<String>();
		ArrayList<String> class_list_dis_start = new ArrayList<String>();
        ArrayList<String> class_sections = new ArrayList<String>();

        pstmt = conn.prepareStatement("SELECT DISTINCT c.class_title, c.class_name, scq.di_time, scq.section_id " +
                                      "FROM classes c, students s, sections_new scq, academic_history_new r " +
                                      "WHERE s.ssn = ? AND s.s_id = r.s_id AND r.section_id = scq.section_id " +
									  "AND c.class_name = scq.course_number ");
        pstmt.setInt(1, Integer.parseInt(selected_ssn));
        rs = pstmt.executeQuery();

		while(rs.next()){
			class_list.add(rs.getString("class_title"));
			class_list_course1.add(rs.getString("class_name"));
			class_list_dis_start.add(rs.getString("di_time"));
            class_sections.add(Integer.toString(rs.getInt("section_id")));
		}
		
		//storing the resultset for conflict schedule
		
		ArrayList<String> class_list2 = new ArrayList<String>();
		ArrayList<String> class_list_course2 = new ArrayList<String>();
		ArrayList<String> class_list_title = new ArrayList<String>();
		ArrayList<String> class_list_course_not = new ArrayList<String>();

//trash part for testing		
/*		pstmt = conn.prepareStatement("SELECT DISTINCT c1.title, c1.course_number " +
											  "FROM sections_of_current_quarter scq1, sections_of_current_quarter scq2, classes c1, classes c2 " +
											  "WHERE scq1.course_number = ? AND scq2.course_number <> ? AND c1.course_number = scq2.course_number AND scq1.lec_week = scq2.lec_week " +
											  "AND c2.course_number = scq1.course_number AND scq1.lec_start_time <= scq2.lec_end_time AND scq1.lec_end_time >= scq2.lec_start_time");
				pstmt.setString(1, "CSE8A");
				pstmt.setString(2, "CSE8A");
				rs = pstmt.executeQuery();
				while(rs.next()){
					class_list2.add(class_list.get(0));
					class_list_course2.add(class_list_course1.get(0));
					class_list_title.add(rs.getString("title"));
					class_list_course_not.add(rs.getString("course_number"));
				}
*/				
		
		for(int i = 0; i < class_list.size();i++){
			String class_l = class_list.get(i);
			String class_course = class_list_course1.get(i);
            String section_id = class_sections.get(i);

			if(class_list_dis_start.get(i) != null){
				//retriving the conflict with lecture time to lecture time
				pstmt = conn.prepareStatement("SELECT DISTINCT  c1.class_title, c1.class_name " +
											  "FROM sections_new scq1, sections_new scq2, classes c1, classes c2 " +
											  "WHERE scq1.section_id = ? AND scq2.course_number <> ? AND c1.class_name = scq2.course_number AND " +
											  "(scq1.le_mon = scq2.le_mon OR scq1.le_tues = scq2.le_tues OR scq1.le_wed = scq2.le_wed OR " +
                                              "scq1.le_thur = scq2.le_thur OR scq1.le_fri = scq2.le_fri) " +
                                              "AND c2.class_name = scq1.course_number AND scq1.lec_start_time < scq2.lec_end_time AND " +
                                              "scq1.lec_end_time > scq2.lec_start_time");
				pstmt.setInt(1, Integer.parseInt(section_id));
				pstmt.setString(2, class_course);
				rs = pstmt.executeQuery();
				while(rs.next()){
					class_list2.add(class_l);
					class_list_course2.add(class_course);
					class_list_title.add(rs.getString("class_title"));
					class_list_course_not.add(rs.getString("class_name"));
				}
				
                
				//retriving the conflict with discussion time to lecture time
				pstmt = conn.prepareStatement("SELECT DISTINCT  c1.class_title, c1.class_name " +
                                              "FROM sections_new scq1, sections_new scq2, classes c1, classes c2 " +
                                              "WHERE scq1.section_id = ? AND scq2.course_number <> ? AND c1.class_name = scq2.course_number AND " +
                                              "(scq1.di_mon = scq2.le_mon OR scq1.di_tues = scq2.le_tues OR scq1.di_wed = scq2.le_wed OR " +
                                              "scq1.di_thur = scq2.le_thur OR scq1.di_fri = scq2.le_fri) " +
                                              "AND c2.class_name = scq1.course_number AND scq1.dis_start_time < scq2.lec_end_time AND " +
                                              "scq1.dis_end_time > scq2.lec_start_time");
				pstmt.setInt(1, Integer.parseInt(section_id));
				pstmt.setString(2, class_course);
				rs = pstmt.executeQuery();
				while(rs.next()){
					class_list2.add(class_l);
					class_list_course2.add(class_course);
					class_list_title.add(rs.getString("class_title"));
                    class_list_course_not.add(rs.getString("class_name"));
				}
				
				//retriving the conflict with discussion time to discussion time
				pstmt = conn.prepareStatement("SELECT DISTINCT  c1.class_title, c1.class_name " +
                                              "FROM sections_new scq1, sections_new scq2, classes c1, classes c2 " +
                                              "WHERE scq1.section_id = ? AND scq2.course_number <> ? AND c1.class_name = scq2.course_number AND " +
                                              "(scq1.di_mon = scq2.di_mon OR scq1.di_tues = scq2.di_tues OR scq1.di_wed = scq2.di_wed OR " +
                                              "scq1.di_thur = scq2.di_thur OR scq1.di_fri = scq2.di_fri) " +
                                              "AND c2.class_name = scq1.course_number AND scq1.dis_start_time < scq2.dis_end_time AND " +
                                              "scq1.dis_end_time > scq2.dis_start_time");
				pstmt.setInt(1, Integer.parseInt(section_id));
				pstmt.setString(2, class_course);
				rs = pstmt.executeQuery();
				while(rs.next()){
					class_list2.add(class_l);
					class_list_course2.add(class_course);
					class_list_title.add(rs.getString("class_title"));
                    class_list_course_not.add(rs.getString("class_name"));
				}
                

			}
			else{
				pstmt = conn.prepareStatement("SELECT DISTINCT  c1.class_title, c1.class_name " +
                                              "FROM sections_new scq1, sections_new scq2, classes c1, classes c2 " +
                                              "WHERE scq1.section_id = ? AND scq2.course_number <> ? AND c1.class_name = scq2.course_number AND " +
                                              "(scq1.le_mon = scq2.le_mon OR scq1.le_tues = scq2.le_tues OR scq1.le_wed = scq2.le_wed OR " +
                                              "scq1.le_thur = scq2.le_thur OR scq1.le_fri = scq2.le_fri) " +
                                              "AND c2.class_name = scq1.course_number AND scq1.lec_start_time < scq2.lec_end_time AND " +
                                              "scq1.lec_end_time > scq2.lec_start_time");
				pstmt.setInt(1, Integer.parseInt(section_id));
				pstmt.setString(2, class_course);
				rs = pstmt.executeQuery();
				while(rs.next()){
					class_list2.add(class_l);
					class_list_course2.add(class_course);
					class_list_title.add(rs.getString("class_title"));
                    class_list_course_not.add(rs.getString("class_name"));
				}

			}
		}

%>
    <tr>
        <td>
            Currently displaying the class schedule and the classes <%= selected_name %> cannot take
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
                <tr>
                    <th>Class Title</th>
                    <th>Course Number</th>
					<th>Conflicted Class Title</th>
                    <th>Conflicted Course Number</th>
                </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                for(int i = 0; i < class_list2.size();i++){
			%>

                <tr>
                    <%-- Get the class_title --%>
                    <td>
                        <%= class_list2.get(i) %>
                    </td>
					<%-- Get the class_course_number --%>
                    <td>
                        <%= class_list_course2.get(i) %>
                    </td>
					<%-- Get the class_title that has conflict with the class --%>
                    <td>
                        <%= class_list_title.get(i) %>
                    </td>
					<%-- Get the class_course number that has conflict with the class --%>
                    <td>
                        <%= class_list_course_not.get(i) %>
                    </td>
                    
                </tr>
				
            <%
                }
            %>
            </table>
        </td>
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
</body>

</html>

