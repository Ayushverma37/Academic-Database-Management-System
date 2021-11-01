-- this file contains stored procedures

-- procedure for student registration in a course
-- procedures to be implemented: allot_section()
CREATE OR REPLACE FUNCTION registration_in_course(student_id char(11), in_course_id char(5), in_section_id INTEGER)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
section_record INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    FOR section_record in EXECUTE format('select S.section_id from %I as S where S.course_id = %L;', 'section_'||temp_semester||'_'||temp_year, in_course_id) LOOP 
        if in_section_id = section_record then 
            EXECUTE format('INSERT INTO %I values(%L, %L, %L);','student_registration'||'_'||temp_semester||'_'||temp_year, student_id, in_course_id, in_section_id);
            return;
        end if;
    end loop;
END;
$$;

CREATE OR REPLACE FUNCTION offering_course(course_id char(5), ins_id INTEGER, ins_id2 INTEGER, ins_id3 INTEGER, cgpa_criterion numeric, maxCapacity INTEGER, timetable_slot varchar(10),all_dept BOOLEAN, all_year BOOLEAN, dept1 char(5), dept2 char(5), dept3 char(5), year1 INTEGER, year2 INTEGER, year3 INTEGER)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
curr_user VARCHAR(20);
user_dean VARCHAR(20);
ins_login VARCHAR(20);
BEGIN
    select current_user into curr_user;
    user_dean:= 'postgres';
    ins_login:='instructor_'||ins_id;
    IF (curr_user != ins_login) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to offer course';
    END IF;
    IF (curr_user = ins_login) OR (curr_user=user_dean) THEN
    BEGIN
        select semester into temp_semester from current_sem_and_year;
        select year into temp_year from current_sem_and_year;
        EXECUTE format('INSERT INTO %I values(%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L);', 'course_offering_'||temp_semester||'_'||temp_year, course_id, ins_id, ins_id2, ins_id3, cgpa_criterion, maxCapacity, timetable_slot,all_dept, all_year, dept1, dept2, dept3, year1, year2, year3);
    END;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION entry_section(section_id INTEGER, course_id CHAR(5), ins_id INTEGER, classroom char(5))
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
curr_user VARCHAR(20);
user_dean VARCHAR(20);
ins_login VARCHAR(20);
BEGIN
    select current_user into curr_user;
    user_dean:= 'postgres';
    ins_login:= 'instructor_'||ins_id;
    IF (curr_user != ins_login) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to make an entry into section table';
    END IF;
    IF (curr_user = ins_login) OR (curr_user=user_dean) THEN
    BEGIN
        select semester into temp_semester from current_sem_and_year;
        select year into temp_year from current_sem_and_year;
        EXECUTE format('INSERT INTO %I values(%L, %L, %L, %L);', 'section'||'_'||temp_semester||'_'||temp_year, section_id, course_id, ins_id, classroom);
    END;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION course_catalog_entry(course_id char(5), L numeric, T numeric, P numeric, S numeric, C numeric, course_id1 char(5), course_id2 char(5), course_id3 char(5), course_id_Not_Elligible char(5))
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
BEGIN
    EXECUTE format('INSERT INTO Course_Catalog values(%L, %L, %L, %L, %L, %L, %L, %L, %L, %L);',course_id, L, T, P, S, C, course_id1, course_id2, course_id3, course_id_Not_Elligible);
END;
$$;

CREATE OR REPLACE FUNCTION Timetable_slot_list_entry(timetable_slot varchar(10))
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
BEGIN
    EXECUTE format('INSERT INTO Timetable_slot_list values(%L);', timetable_slot);
END;
$$;

-- Procedure for updating grades in trans student table when grades are uploaded by instructor in course grade table
CREATE OR REPLACE FUNCTION update_grade_in_trans(input_course_id char(5))
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
curr_student_id char(11);
grade_row record;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    FOR grade_row in EXECUTE format('select * from %I', 'grade_'||input_course_id||'_'||temp_semester||'_'||temp_year) LOOP
        if grade_row.grade IS NOT NULL THEN
            EXECUTE format('INSERT INTO %I VALUES(%L, %L, %L, %L)', 'trans_'||grade_row.student_id, input_course_id, temp_semester, temp_year, grade_row.grade);
        end if;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION _add_to_course_grade(input_course_id char(5))
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_semester INTEGER;
temp_year INTEGER;
registration_row record;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    for registration_row in EXECUTE format('select * from %I as SR where SR.course_id = %L;', 'student_registration_'||temp_semester||'_'||temp_year,input_course_id) LOOP
        EXECUTE format('INSERT INTO %I values(%L, %L);', 'grade_'||input_course_id||'_'||temp_semester||'_'||temp_year, registration_row.student_id, NULL);
    END LOOP;
END;
$$;

-- procedure to upload grades to course_grade table by instructor from .csv file
CREATE OR REPLACE FUNCTION get_grades_from_file(file_path VARCHAR(100), in_course_id char(5), ins_id integer)
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_semester integer;
temp_year integer;
comma_literal char(1);
curr_user VARCHAR(20);
user_dean VARCHAR(20);
ins_login VARCHAR(20);
BEGIN 
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    select current_user into curr_user;
    user_dean:= 'postgres';
    ins_login:='instructor_'||ins_id;
    IF (curr_user != ins_login) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to offer course';
    END IF;
    IF (curr_user = ins_login) OR (curr_user=user_dean) THEN
    BEGIN
        comma_literal := ',';
        CREATE temp TABLE temp_grade (student_id char(11), grade integer);
        EXECUTE format('copy temp_grade FROM %L DELIMITER %L CSV HEADER;', file_path, comma_literal);
        EXECUTE format('UPDATE %I as gg SET grade = temp_grade.grade FROM temp_grade where gg.student_id = temp_grade.student_id;', 'grade_'||in_course_id||'_'||temp_semester||'_'||temp_year);
        DROP table temp_grade;
    END;
    end if;
END;
$$;

-- procedure for report generation
CREATE OR REPLACE FUNCTION report_generation(in_student_id char(11))
RETURNS NUMERIC 
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_semester integer;
temp_year integer;
trans_student_row record;
cgpa numeric;
BEGIN 
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format('DROP TABLE IF EXISTS %I;', 'report_of_'||in_student_id || '_'||temp_semester||'_'||temp_year);
    EXECUTE format('CREATE TABLE %I (course_id char(5), grade integer);', 'report_of_'||in_student_id || '_'||temp_semester||'_'||temp_year);
    for trans_student_row in EXECUTE format('select * from %I;', 'trans_'||in_student_id) LOOP
        if trans_student_row.semester = temp_semester AND trans_student_row.year = temp_year then 
            EXECUTE format('INSERT into %I values(%L, %L);', 'report_of_'||in_student_id || '_'||temp_semester||'_'||temp_year, trans_student_row.course_id, trans_student_row.grade);
        end if;
    end LOOP;
    cgpa := curr_cgpa(in_student_id);
    return cgpa;
END;
$$;
