-- this file contains stored procedures

-- procedure for student registration in a course
-- procedures to be implemented: allot_section()
CREATE OR REPLACE FUNCTION registration_in_course(student_id char(11), course_id char(5), semester INTEGER, year INTEGER)
RETURNS NULL
LANGUAGE PLPGSQL
AS $$
DECLARE
section_id INTEGER;
BEGIN
    section_id := allot_section();
    EXECUTE format('INSERT INTO Student_Registration values(%L, %L, %L, %L, %L);', student_id, course_id, semester, year, section_id);
END;
$$;
