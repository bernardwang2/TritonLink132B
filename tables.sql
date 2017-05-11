CREATE TABLE academic_history (
    history_id integer NOT NULL,
    s_id integer NOT NULL,
    section_id integer NOT NULL,
    grade text,
    units integer NOT NULL
);

CREATE TABLE buildings (
    building_and_room text NOT NULL
);

CREATE TABLE classes (
    class_id integer NOT NULL,
    class_name text NOT NULL,
    class_title text NOT NULL,
    class_year integer NOT NULL,
    class_quarter text NOT NULL
);

CREATE TABLE colleges (
    college text NOT NULL
);

CREATE TABLE courses (
    c_id integer NOT NULL,
    c_name text NOT NULL,
    d_name text NOT NULL,
    c_unit_range integer NOT NULL,
    grading_option text NOT NULL,
    lab_work text NOT NULL,
    instructor_consent text NOT NULL,
    CONSTRAINT lower CHECK ((c_unit_range > 0)),
    CONSTRAINT upper CHECK ((c_unit_range < 9))
);

CREATE TABLE dates (
    date text NOT NULL
);

CREATE TABLE days (
    day text NOT NULL
);

CREATE TABLE degrees (
    degree_name text NOT NULL,
    d_name text NOT NULL,
    total_units integer NOT NULL
);

CREATE TABLE departments (
    d_id integer NOT NULL,
    d_name text NOT NULL,
    s_id integer NOT NULL,
    CONSTRAINT id CHECK ((d_id > 0))
);

CREATE TABLE extra_degrees (
    degree_name text NOT NULL
);

CREATE TABLE faculty (
    faculty_name text NOT NULL,
    faculty_title text NOT NULL
);

CREATE TABLE grades (
    grade text NOT NULL
);

CREATE TABLE graduates (
    s_id integer NOT NULL,
    d_name text NOT NULL,
    ms_or_phd text NOT NULL,
    candidacy text DEFAULT '" "'::text
);

CREATE TABLE minors (
    minor text NOT NULL
);

CREATE TABLE prerequisites (
    c_name text NOT NULL,
    pre_cname text NOT NULL
);

CREATE TABLE probations (
    probation_id integer NOT NULL,
    s_id integer NOT NULL,
    p_year integer NOT NULL,
    p_quarter text NOT NULL,
    p_reason text NOT NULL
);

CREATE TABLE quarters (
    quarter text NOT NULL
);

CREATE TABLE review_sessions (
    rs_id integer NOT NULL,
    class_id integer NOT NULL,
    date text NOT NULL,
    "time" text NOT NULL,
    building_and_room text NOT NULL
);

CREATE TABLE sections (
    section_id integer NOT NULL,
    class_id integer NOT NULL,
    instructor text NOT NULL,
    section_limit integer NOT NULL,
    meeting_type text NOT NULL,
    days text NOT NULL,
    "time" text NOT NULL,
    building_and_room text NOT NULL,
    CONSTRAINT sections_section_limit_check CHECK ((section_limit > 0))
);

CREATE TABLE students (
    s_id integer NOT NULL,
    first_name text NOT NULL,
    middle_name text DEFAULT '" "'::text,
    last_name text NOT NULL,
    ssn integer NOT NULL,
    residency text NOT NULL,
    enrolled text NOT NULL,
    extra_degree text NOT NULL,
    CONSTRAINT "s_id length" CHECK ((s_id > 9999)),
    CONSTRAINT ssn_length CHECK ((ssn > 99999999))
);

CREATE TABLE times (
    "time" text NOT NULL
);

CREATE TABLE undergraduates (
    s_id integer NOT NULL,
    college text NOT NULL,
    major text NOT NULL,
    minor text NOT NULL,
    ms_program text NOT NULL
);

CREATE TABLE waitlists (
    section_id integer NOT NULL,
    student_id integer NOT NULL
);

CREATE TABLE years (
    year integer NOT NULL,
    CONSTRAINT years_year_check CHECK ((year >= 1950))
);

