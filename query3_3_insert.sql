CREATE OR REPLACE FUNCTION total_course_grade()
RETURNS trigger AS
$$
DECLARE
        course_number_c TEXT;
        instructor_c    TEXT;
        grade_c         TEXT;
        count_c         INT;

BEGIN
    -- CASE GRADE 'A'
    IF NEW.grade = 'A+' OR NEW.grade = 'A' OR NEW.grade = 'A-' THEN
    
        SELECT cp.course_number, cp.instructor, cp.grade, cp.count
        INTO course_number_c, instructor_c, grade_c, count_c
        FROM cpg cp, sections_new cl
        WHERE cp.grade = 'A'  AND cp.course_number = cl.course_number AND cp.instructor = cl.instructor
              AND cl.section_id = NEW.section_id;
        
        IF count_c IS NULL THEN
            SELECT course_number, instructor INTO course_number_c, instructor_c
            FROM sections_new WHERE section_id = NEW.section_id;
            
            INSERT INTO cpg (course_number, instructor, grade, count)
            VALUES (course_number_c, instructor_c, 'A', 1);
            
        ELSE
            count_c = count_c + 1;
            UPDATE cpg SET count = count_c
            WHERE grade = 'A'  AND course_number = course_number_c AND instructor = instructor_c;
        END IF;
        
    -- CASE GRADE 'B'
    ELSIF NEW.grade = 'B+' OR NEW.grade = 'B' OR NEW.grade = 'B-' THEN
    
        SELECT cp.course_number, cp.instructor, cp.grade, cp.count
        INTO course_number_c, instructor_c, grade_c, count_c
        FROM cpg cp, sections_new cl
        WHERE cp.grade = 'B'  AND cp.course_number = cl.course_number AND cp.instructor = cl.instructor
              AND cl.section_id = NEW.section_id;
        
        IF count_c IS NULL THEN
            SELECT course_number, instructor INTO course_number_c, instructor_c
            FROM sections_new WHERE section_id = NEW.section_id;
            
            INSERT INTO cpg (course_number, instructor, grade, count)
            VALUES (course_number_c, instructor_c, 'B', 1);
            
        ELSE
            count_c = count_c + 1;
            UPDATE cpg SET count = count_c
            WHERE grade = 'B'  AND course_number = course_number_c AND instructor = instructor_c;
        END IF;
    
    -- CASE GRADE 'C'
    ELSIF NEW.grade = 'C+' OR NEW.grade = 'C' OR NEW.grade = 'C-' THEN
    
        SELECT cp.course_number, cp.instructor, cp.grade, cp.count
        INTO course_number_c, instructor_c, grade_c, count_c
        FROM cpg cp, sections_new cl
        WHERE cp.grade = 'C'  AND cp.course_number = cl.course_number AND cp.instructor = cl.instructor
              AND cl.section_id = NEW.section_id;
        
        IF count_c IS NULL THEN
            SELECT course_number, instructor INTO course_number_c, instructor_c
            FROM sections_new WHERE section_id = NEW.section_id;
            
            INSERT INTO cpg (course_number, instructor, grade, count)
            VALUES (course_number_c, instructor_c, 'C', 1);
            
        ELSE
            count_c = count_c + 1;
            UPDATE cpg SET count = count_c
            WHERE grade = 'C'  AND course_number = course_number_c AND instructor = instructor_c;
        END IF;
        
    -- CASE GRADE 'D'
    ELSIF NEW.grade = 'D+' OR NEW.grade = 'D' OR NEW.grade = 'D-' THEN
    
        SELECT cp.course_number, cp.instructor, cp.grade, cp.count
        INTO course_number_c, instructor_c, grade_c, count_c
        FROM cpg cp, sections_new cl
        WHERE cp.grade = 'D'  AND cp.course_number = cl.course_number AND cp.instructor = cl.instructor
              AND cl.section_id = NEW.section_id;
        
        IF count_c IS NULL THEN
            SELECT course_number, instructor INTO course_number_c, instructor_c
            FROM sections_new WHERE section_id = NEW.section_id;
            
            INSERT INTO cpg (course_number, instructor, grade, count)
            VALUES (course_number_c, instructor_c, 'D', 1);
            
        ELSE
            count_c = count_c + 1;
            UPDATE cpg SET count = count_c
            WHERE grade = 'D'  AND course_number = course_number_c AND instructor = instructor_c;
        END IF;
    
    -- CASE GRADE 'F'
    ELSE
   
        SELECT cp.course_number, cp.instructor, cp.grade, cp.count
        INTO course_number_c, instructor_c, grade_c, count_c
        FROM cpg cp, sections_new cl
        WHERE cp.grade = 'other'  AND cp.course_number = cl.course_number AND cp.instructor = cl.instructor
              AND cl.section_id = NEW.section_id;
        
        IF count_c IS NULL THEN
            SELECT course_number, instructor INTO course_number_c, instructor_c
            FROM sections_new WHERE section_id = NEW.section_id;
            
            INSERT INTO cpg (course_number, instructor, grade, count)
            VALUES (course_number_c, instructor_c, 'other', 1);
            
        ELSE
            count_c = count_c + 1;
            UPDATE cpg SET count = count_c
            WHERE grade = 'other'  AND course_number = course_number_c AND instructor = instructor_c;
        END IF;
        
    END IF;
    RETURN NEW;
END;
$$
Language plpgsql;

CREATE TRIGGER total_course_grade
BEFORE INSERT ON academic_history_new
FOR EACH ROW EXECUTE PROCEDURE total_course_grade();
