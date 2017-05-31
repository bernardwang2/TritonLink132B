<html>
<HEAD><TITLE>CSE132B Webapp: Report 2b</TITLE></HEAD>
<BODY>  <FONT SIZE="5">Report 2b</FONT> <P />



<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.time.LocalDate"%>



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

    // Retrieve all sections in the current quarter
    pstmt = conn.prepareStatement("SELECT * FROM sections_new ORDER BY section_id");
    rs = pstmt.executeQuery();
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
                <form action="report_2b.jsp" method="POST">
                <input type="hidden" name="action" value="submit"/>

                <td>
                    <p>Schedule a review session for the following section: </p>
                </td>

                <td>
                    <select name="selected_section">
                    <option value="def">--SELECT ONE--</option>
                <%
                    while(rs.next()){
                %>
                        <option value="<%= rs.getInt("section_id") %>"><%= rs.getInt("section_id") +" "+rs.getString("course_number") %></option>
                <%
                    }
                %>
                    </select>
                </td>
                
                <td>
                    <p>between dates (in format MM/dd/yyyy):</p>
                </td>

                <td>
                    <input type="text" name="start_date"/>
                </td>

                <td>
                    <input type="text" name="end_date"/>
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

        // Retrieve the section ID
        String selected_section = request.getParameter("selected_section");

        // Retrieve the list of conflicted times
        pstmt = conn.prepareStatement("SELECT s.le_mon, s.le_tues, s.le_wed, s.le_thur, s.le_fri, s.le_time, " +
                                      "       s.di_mon, s.di_tues, s.di_wed, s.di_thur, s.di_fri, s.di_time " +
                                      "FROM academic_history_new r, sections_new s " +
                                      "WHERE r.section_id IS NOT NULL AND r.section_id = s.section_id AND r.s_id IN " +
                                      "  (SELECT a.s_id " +
                                      "   FROM academic_history_new a " +
                                      "   WHERE a.section_id = ? " +
                                      "  )");
        pstmt.setInt(1, Integer.parseInt(selected_section));
        rs = pstmt.executeQuery();

        ArrayList<String> monday_conflict_times = new ArrayList<String>();
        ArrayList<String> tuesday_conflict_times = new ArrayList<String>();
        ArrayList<String> wednesday_conflict_times = new ArrayList<String>();
        ArrayList<String> thursday_conflict_times = new ArrayList<String>();
        ArrayList<String> friday_conflict_times = new ArrayList<String>();
        while(rs.next()){
            if(rs.getString("le_mon").equals("y")){
                monday_conflict_times.add(rs.getString("le_time"));
            }
            if(rs.getString("le_tues").equals("y")){
                tuesday_conflict_times.add(rs.getString("le_time"));
            }
            if(rs.getString("le_wed").equals("y")){
                wednesday_conflict_times.add(rs.getString("le_time"));
            }
            if(rs.getString("le_thur").equals("y")){
                thursday_conflict_times.add(rs.getString("le_time"));
            }
            if(rs.getString("le_fri").equals("y")){
                friday_conflict_times.add(rs.getString("le_time"));
            }
            if(rs.getString("di_mon").equals("y")){
                monday_conflict_times.add(rs.getString("di_time"));
            }
            if(rs.getString("di_tues").equals("y")){
                tuesday_conflict_times.add(rs.getString("di_time"));
            }
            if(rs.getString("di_wed").equals("y")){
                wednesday_conflict_times.add(rs.getString("di_time"));
            }
            if(rs.getString("di_thur").equals("y")){
                thursday_conflict_times.add(rs.getString("di_time"));
            }
            if(rs.getString("di_fri").equals("y")){
                friday_conflict_times.add(rs.getString("di_time"));
            }
        }

        // Retrieve the possible review session times
        ArrayList<String> time_list = new ArrayList<String>();
        pstmt = conn.prepareStatement("SELECT * FROM times_new");
        rs = pstmt.executeQuery();
        while(rs.next()){
            time_list.add(rs.getString("time"));
        }
        
        // Retrieve the dates by LocalDate and DateTimeFormatter class
        String start_date_string = request.getParameter("start_date");
        String end_date_string = request.getParameter("end_date");
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/dd/yyyy");
        DateTimeFormatter formatter_out = DateTimeFormatter.ofPattern("MMMM dd EEEE yyyy");
        LocalDate start_date = LocalDate.parse(start_date_string, formatter);
        LocalDate end_date = LocalDate.parse(end_date_string, formatter);
    %>
    <tr>
        <td>
            Scheduling a review session for section <%= selected_section %>
        </td>
    </tr>

    <tr>
        <td>
            <table border="1">
    <%
        // Iterate through the start date and end date + time of each day
        for (LocalDate date = start_date; date.isBefore(end_date.plusDays(1)); date = date.plusDays(1)) {
            String date_out = date.format(formatter_out);

            for(int i = 0; i < (time_list.size()-1); i++){
            %>
                <tr>
                    <td>
            <%
                switch(date.getDayOfWeek()){
                    case MONDAY:
                        if(monday_conflict_times.contains(time_list.get(i))){
                            %>
                            <%= "---" %>
                            <%
                        }
                        else{
                            %>
                            <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                            <%
                        }
                        break;
                    case TUESDAY:
                        if(tuesday_conflict_times.contains(time_list.get(i))){
                            %>
                            <%= "---" %>
                            <%
                        }
                        else{
                            %>
                            <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                            <%
                        }
                        break;
                    case WEDNESDAY:
                        if(wednesday_conflict_times.contains(time_list.get(i))){
                            %>
                            <%= "---" %>
                            <%
                        }
                        else{
                            %>
                            <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                            <%
                        }
                        break;
                    case THURSDAY:
                        if(thursday_conflict_times.contains(time_list.get(i))){
                            %>
                            <%= "---" %>
                            <%
                        }
                        else{
                            %>
                            <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                            <%
                        }
                        break;
                    case FRIDAY:
                        if(friday_conflict_times.contains(time_list.get(i))){
                            %>
                            <%= "---" %>
                            <%
                        }
                        else{
                            %>
                            <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                            <%
                        }
                        break;
                    case SATURDAY:
                        %>
                        <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                        <%
                        break;
                    case SUNDAY:
                        %>
                        <%= date_out + " " + time_list.get(i) + " - " + time_list.get(i+1) %>
                        <%
                        break;
                    default:
                        break;
                }
    %>
                    </td>
                </tr>
    <%
            }
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

