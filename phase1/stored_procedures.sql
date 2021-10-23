-- this file contains stored procedures

-- procedure for student registration in a course
-- procedures to be implemented: allot_section()
CREATE OR REPLACE FUNCTION registration_in_course(student_id char(11), course_id char(5), section_id INTEGER)
RETURNS NULL
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format('INSERT INTO %I values(%L, %L, %L);','student_registration'||'_'||temp_semester||'_'||temp_year, student_id, course_id, section_id);
END;
$$;

CREATE OR REPLACE FUNCTION offering_course(course_id char(5), ins_id INTEGER, ins_id2 INTEGER, ins_id3 INTEGER, cgpa_criterion numeric, maxCapacity INTEGER, course_id_Not_Elligible char(5), timetable_slot varchar(10), dept1 char(5), dept2 char(5), dept3 char(5), year1 INTEGER, year2 INTEGER, year3 INTEGER)
RETURNS NULL
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format('INSERT INTO %I values(%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L);', 'course_offering_'||temp_semester||'_'||temp_year, course_id, ins_id, ins_id2, ins_id3, cgpa_criterion, maxCapacity, course_id_Not_Elligible, timetable_slot, dept1, dept2, dept3, year1, year2, year3);
END;
$$;


CREATE OR REPLACE FUNCTION course_catalog_entry(course_id char(5), L numeric, T numeric, P numeric, S numeric, C numeric, course_id1 char(5), course_id2 char(5), course_id3 char(5))
RETURNS NULL
LANGUAGE PLPGSQL
AS $$
DECLARE
BEGIN
    EXECUTE format('INSERT INTO Course_Catalog values(%L, %L, %L, %L, %L, %L, %L, %L, %L);',course_id, L, T, P, S, C, course_id1, course_id2, course_id3);
END;
$$;

CREATE OR REPLACE FUNCTION Timetable_slot_list_entry(timetable_slot char(5))
RETURNS NULL
LANGUAGE PLPGSQL
AS $$
DECLARE
BEGIN
    EXECUTE format('INSERT INTO Timetable_slot_list values(%L);', timetable_slot);
END;
$$;
