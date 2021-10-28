-- implementation of stores procedures and triggers


--trigger and procedure to ensure that a student takes only 1 course in a timetable slot
CREATE OR REPLACE FUNCTION check_course_in_timetable_slot()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
new_course_timetable_slot varchar(10);
old_course_timetable_slot varchar(10);
student_registration_row record;
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- select timetable_slot into new_course_timetable_slot from Course_Offering as CO where NEW.course_id = CO.course_id;
    EXECUTE format('select timetable_slot from %I as CO where CO.course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id)  into new_course_timetable_slot;
    -- FOR student_registration_row in select * from Student_Registration as SR where SR.student_id = NEW.student_id
    FOR student_registration_row in EXECUTE format('select * from %I as SR where SR.student_id = %L;', 'student_registration_'||temp_semester||'_'||temp_year, NEW.student_id) LOOP
        -- select timetable_slot into old_course_timetable_slot from Course_Offering as CO where student_registration_row.course_id = CO.course_id;
        EXECUTE format('select timetable_slot from %I as CO where CO.course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, student_registration_row.course_id) into old_course_timetable_slot;
        if new_course_timetable_slot = old_course_timetable_slot then
            raise exception 'INSERTION FAILED: Course in timetable slot already exists';
        end if;
    END LOOP;
    RETURN NEW;
END;
$$;

/*CREATE TRIGGER course_in_timetable_slot
Before INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE check_course_in_timetable_slot();*/



-- ***********************************************************




-- procedure to get credits registered in previous 2 semesters
-- modify if previous semester are in different year than current one -- done
CREATE OR REPLACE FUNCTION get_registered_credits_previous_2_semester(input_student_id char(11), input_semester INTEGER, input_year INTEGER)
RETURNS NUMERIC
LANGUAGE PLPGSQL
AS $$
DECLARE
trans_student_row record;
credit_of_previous NUMERIC:=0;
temp NUMERIC;
BEGIN
    for trans_student_row in EXECUTE format('select * from %I;', 'trans_'||input_student_id) LOOP
        if trans_student_row.semester = input_semester-1 AND trans_student_row.year = input_year AND trans_student_row.grade >= 4.0 THEN
            select C into temp from Course_Catalog as CC where CC.course_id = trans_student_row.course_id;
            credit_of_previous := credit_of_previous + temp;
        end if;
        if trans_student_row.semester = input_semester+1 AND trans_student_row.year = input_year-1 AND trans_student_row.grade >= 4.0 THEN
            select C into temp from Course_Catalog as CC where CC.course_id = trans_student_row.course_id;
            credit_of_previous := credit_of_previous + temp;
        end if;
        if trans_student_row.semester = input_semester AND trans_student_row.year = input_year-1 AND trans_student_row.grade >= 4.0 THEN
            select C into temp from Course_Catalog as CC where CC.course_id = trans_student_row.course_id;
            credit_of_previous := credit_of_previous + temp;
        end if;
    END LOOP;
    return credit_of_previous;
END;
$$;

-- procedure to get credits registered in this semester
CREATE OR REPLACE FUNCTION get_credits_registered_in_this_sem(input_student_id char(11))
RETURNS NUMERIC
LANGUAGE PLPGSQL
AS $$
DECLARE
registration_row record;
credits_current NUMERIC:=0;
temp NUMERIC;
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    --for registration_row in select * from Student_Registration as SR where SR.student_id = input_student_id AND SR.semester = input_semester AND SR.year = input_year LOOP
    for registration_row in EXECUTE format('select * from %I as SR where SR.student_id = %L;', 'student_registration_'||temp_semester||'_'||temp_year, input_student_id) LOOP
        select C into temp from Course_Catalog as CC where CC.course_id = registration_row.course_id;
        credits_current := credits_current + temp;
    END LOOP;
    return credits_current;
END;
$$;

--implement procedure for ticket generation

-- trigger and stored procedure to check for credit limit of 1.25
-- procedures to be implemented:
-- get_registered_credits_previous_2_semester
-- get_credits_registered_in_this_sem
-- ticket generation function call
CREATE OR REPLACE FUNCTION z_check_credit_limit()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
credits_registered numeric;
max_credits_allowed numeric;
credits_in_this_sem numeric;
credits_for_new_course numeric;
temp_semester INTEGER;
temp_year INTEGER;
stud_batch INTEGER;
BEGIN
    IF stud_batch<temp_year THEN
    BEGIN
        select semester into temp_semester from current_sem_and_year;
        select year into temp_year from current_sem_and_year;
        select batch into stud_batch from Student where NEW.student_id=Student.student_id;
        credits_registered := get_registered_credits_previous_2_semester(NEW.student_id, temp_semester, temp_year);
        max_credits_allowed := 1.25*credits_registered;
        credits_in_this_sem := get_credits_registered_in_this_sem(NEW.student_id);
        select CC.C into credits_for_new_course from Course_Catalog as CC where CC.course_id = NEW.course_id;
        if credits_for_new_course + credits_in_this_sem > max_credits_allowed then
            --ticket generation function call
            EXECUTE format('INSERT into %I values(%L, %L);','ticket_student_'||NEW.student_id, NEW.course_id, NULL);
            raise exception 'Credit limit exceeded, ticket generated';
        end if;
    END;
    END IF;
    return NEW;
END;
$$;

/*CREATE TRIGGER credit_limit_trigger
Before INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE check_credit_limit();*/








-- **************************************************************************************


-- dean will run a procedure to update grade
-- update grade in student table when a new grade is entered in course_grade table
/*CREATE OR REPLACE FUNCTION update_grade_in_trans_student(input_course_id char(11), input_semester INTEGER, input_year INTEGER)
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    EXECUTE format('UPDATE %I as TS set TS.grade = %L where TS.course_id = %L and TS.semester = %L and TS.year = %L;', 'trans_'||NEW.student_id, NEW.grade, input_course_id, input_semester, input_year);
    return NULL;
END;
$$;

-- Trigger created when making table 
*/

-- *************************************************************************************************

-- tigger to create new table for every new entry into course offering
-- as well as the corresponding trigger to update grade in trans_student table
CREATE OR REPLACE FUNCTION create_course_grade_table()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE 
temp_semester INTEGER;
temp_year INTEGER;
temp_student_id char(11);
temp_ins_id integer;
temp_batch_adviser record;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format('CREATE TABLE %I (student_id char(11) PRIMARY KEY, grade INTEGER);', 'grade_' || NEW.course_id || '_' || temp_semester || '_' || temp_year);
    -- FOR temp_student_id in select student_id from student LOOP 
    --     EXECUTE format('REVOKE ALL ON %I TO %I;', 'grade_' || NEW.course_id || '_' || temp_semester || '_' || temp_year, temp_student_id);
    -- END LOOP;
    
    EXECUTE format('GRANT ALL ON %I TO %I;', 'grade_' || NEW.course_id || '_' || temp_semester || '_' || temp_year, 'instructor_'||NEW.ins_id);


    FOR temp_batch_adviser in select * from batch_adviser LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'grade_' || NEW.course_id || '_' || temp_semester || '_' || temp_year, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
    END LOOP;
    return NULL;
END;
$$;

/*CREATE TRIGGER course_grade_table
AFTER INSERT
ON Course_Offering
FOR EACH ROW
EXECUTE PROCEDURE create_course_grade_table();*/



-- *****************************************************************************************



-- trigger to create new table for every new entry into student table
CREATE OR REPLACE FUNCTION create_trans_student_table()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
temp_ins_id integer;
temp_batch_adviser record;
BEGIN
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, semester integer NOT NULL, year integer NOT NULL, grade INTEGER NOT NULL);', 'trans_'||NEW.student_id );
    
    --EXECUTE format('GRANT SELECT ON %I TO %I;', 'trans_'||NEW.student_id, NEW.student_id);

    FOR temp_ins_id in (select ins_id from instructor) LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'trans_'||NEW.student_id, 'instructor_'||temp_ins_id);
    END LOOP;

    FOR temp_batch_adviser in select * from batch_adviser LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'trans_'||NEW.student_id, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
    END LOOP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trans_student_grade
BEFORE INSERT
ON Student
FOR EACH ROW
EXECUTE PROCEDURE create_trans_student_table();




-- ****************************************************************************************



--trigger and procedure to check if student meets the pre-requisites of the course before registering
create or replace function get_prereq (cid char(5), stud_id char(11))
returns table (course char(5),grade INTEGER)
LANGUAGE plpgsql AS $$
begin
return query EXECUTE format('select course_id, grade from %I as TS where TS.course_id=%L and TS.grade>=4.0;', 'trans_'||stud_id, cid);
end; $$;



CREATE OR REPLACE FUNCTION _check_prerequisites()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
prereq1 char(5);
prereq2 char(5);
prereq3 char(5);
BEGIN
    select course_id1, course_id2, course_id3 into prereq1, prereq2, prereq3 from Course_Catalog as CC where CC.course_id=NEW.course_id;
    IF prereq1 IS NOT NULL THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq1,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq1;
        END IF;
    END;
    END IF;
    IF prereq2 IS NOT NULL THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq2,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq2;
        END IF;
    END;
    END IF;
    IF prereq3 IS NOT NULL THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq3,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq3;
        END IF;
    END;
    END IF;
    return NEW;
END;
$$;

--trigger and procedure to check if student has done course_id_not_eligible course
create or replace function get_current_course_prohibition(cid char(5), stud_id char(11))
returns table (course char(5),grade INTEGER)
LANGUAGE plpgsql AS $$
begin
return query EXECUTE format('select course_id, grade from %I as TS where TS.course_id=%L and TS.grade>=4.0;', 'trans_'||stud_id, cid);
end; $$;

create or replace function get_course_prohibition(cid char(5), stud_id char(11))
returns table (course char(5),grade INTEGER)
LANGUAGE plpgsql AS $$
begin
return query EXECUTE format('select course_id, grade from %I as TS where TS.course_id=%L and TS.grade>=4.0;', 'trans_'||stud_id, cid);
end; $$;

CREATE OR REPLACE FUNCTION _check_course_id_Not_Elligible()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
course_prohibited char(5);
BEGIN
    select course_id_Not_Elligible into course_prohibited from Course_Catalog as CC where CC.course_id=NEW.course_id;
    IF EXISTS (select * from get_current_course_prohibition(NEW.course_id,NEW.student_id)) then
        RAISE EXCEPTION 'Student has already done same course';
    END IF;
    IF course_prohibited IS NOT NULL THEN
    BEGIN
        IF EXISTS (select * from get_course_prohibition(course_prohibited,NEW.student_id)) then
        RAISE EXCEPTION 'Student has already done same type of course';
        END IF;
    END;
    END IF;
    return NEW;
END;
$$;

/*CREATE TRIGGER check_prerequisites
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_prerequisites();*/

--******************************************************************************
--Trigger to check for branches and year at the time of student registration.
CREATE OR REPLACE FUNCTION _check_batchAndYear()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
depart1 char(5);
depart2 char(5);
depart3 char(5);
yr1 INTEGER;
yr2 INTEGER;
yr3 INTEGER;
temp_semester INTEGER;
temp_year INTEGER;
stud_dept char(5);
stud_year INTEGER;
allDept BOOLEAN;
allYear BOOLEAN;

BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    select dept_name into stud_dept from Student where NEW.student_id=Student.student_id;
    select batch into stud_year from Student where NEW.student_id=Student.student_id;
    EXECUTE format('select all_dept from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into allDept;
    EXECUTE format('select all_year from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into allYear;
    EXECUTE format('select dept1 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into depart1;
    EXECUTE format('select dept2 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into depart2;
    EXECUTE format('select dept3 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into depart3;
    EXECUTE format('select year1 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into yr1;
    EXECUTE format('select year2 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into yr2;
    EXECUTE format('select year3 from %I as CO where CO.course_id=%L', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into yr3;
    IF allDept = FALSE THEN
    BEGIN
        IF (depart1 IS NOT NULL AND stud_dept!=depart1) OR (depart2 IS NOT NULL AND stud_dept!=depart2) OR (depart3 IS NOT NULL AND stud_dept!=depart3) THEN
            RAISE EXCEPTION 'Course not floated for this branch';
        END IF;
    END;
    END IF;
    IF allYear = FALSE THEN
    BEGIN
        IF (yr1 IS NOT NULL AND stud_year!=yr1) OR (yr2 IS NOT NULL AND stud_year!=yr2) OR (yr3 IS NOT NULL AND stud_year!=yr3) THEN
            RAISE EXCEPTION 'Course not floated for this year';
        END IF;
    END;
    END IF;
    return NEW;
END;
$$;
--*********************************************************************************



-- *********************************************************************************



--trigger and procedure to check if student meets the cgpa criteria of the course before registering
--procedure to be implemented : gradeOf(student_id) ____ done

create or replace function get_course(stud_id char(11))
returns table (course_id char(5),grade INTEGER)
LANGUAGE plpgsql AS $$
begin
return query EXECUTE format('select course_id, grade from %I as TS;', 'trans_'||stud_id);
end; $$;

CREATE OR REPLACE FUNCTION curr_cgpa(stud_id char(11))
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
curr_course char(5);
curr_credits numeric;
curr_grade integer;
total_credits numeric:=0;
courseAndGrade_row record;
cgpa numeric:=0;
sum numeric:=0;
BEGIN
    for courseAndGrade_row in (select * from get_course(stud_id))
    LOOP
    select courseAndGrade_row.course_id, courseAndGrade_row.grade into curr_course, curr_grade;
    select CC.C into curr_credits from Course_Catalog as CC where CC.course_id=curr_course;
    IF curr_grade IS NOT NULL then
    total_credits:=total_credits+curr_credits;
    sum:=sum+(curr_grade*curr_credits);
    END IF;
    END LOOP;
    cgpa:=sum/total_credits;
    RETURN cgpa;
END;
$$;

CREATE OR REPLACE FUNCTION _check_cgpa()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
curr_grade numeric;
cgpaReq numeric;
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    IF cgpaReq IS NOT NULL THEN
    BEGIN
        curr_grade:=curr_cgpa(NEW.student_id);
        select semester into temp_semester from current_sem_and_year;
        select year into temp_year from current_sem_and_year;
        -- select cgpa_criterion into cgpaReq from Course_Offering as CO where CO.course_id=NEW.course_id;
        EXECUTE format ('select cgpa_criterion from %I as CO where CO.course_id=%L;', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into cgpaReq;
        IF (curr_grade<cgpaReq) THEN
        RAISE EXCEPTION 'cgpa of Student is less than cgpa criteria for this course';
        END IF;
    END;
    END IF;
    return NEW;
END;
$$;

/*CREATE TRIGGER check_cgpa
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_cgpa();*/




-- **************************************************************************************



--trigger and procedure to check if the course max capacity has not been achieved
--procedure to be implemented : maxCapacityOf(course_id) ____ done
CREATE OR REPLACE FUNCTION maxCapacityOf(input_course_id char(5))
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
cap INTEGER:=0;
registration_row record;
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- select count(*) into cap from Student_Registration as SR where SR.course_id=input_course_id AND SR.semester = input_semester AND SR.year = input_year;
    EXECUTE format('select count(*) from %I as SR where SR.course_id= %L;', 'student_registration_'||temp_semester||'_'||temp_year, input_course_id) into cap;
    return cap;
END;
$$;

-- update course offering
CREATE OR REPLACE FUNCTION _check_capacity()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
courseCapacity integer;
currentCapacity integer;
temp_semester integer;
temp_year integer;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    currentCapacity:=maxCapacityOf(NEW.course_id);
    -- select maxCapacity into courseCapacity from Course_Offering as CO where CO.course_id=NEW.course_id;
    EXECUTE format('select maxCapacity from %I as CO where CO.course_id=%L;', 'course_offering_'||temp_semester||'_'||temp_year,NEW.course_id) into courseCapacity;
    IF (courseCapacity IS NOT NULL) AND (currentCapacity>=courseCapacity) THEN
      RAISE EXCEPTION 'Course Capacity has already been reached for % course',NEW.course_id;
    END IF;
    return NEW;
END;
$$;

/*CREATE TRIGGER check_capacity
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_capacity();*/



-- trigger and procedure for checking valid user
CREATE OR REPLACE FUNCTION a_check_valid_user()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
curr_user VARCHAR(20);
user_dean VARCHAR(20); 
BEGIN
    select current_user into curr_user;
    user_dean:= 'postgres';
    IF (curr_user != NEW.student_id) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to register in course';
    END IF;
    return NEW;
END;
$$;



-- *****************************************************************************************


-- trigger on student registration so that whenever a new entry is created into student registration, a new entry is created in course grade table
-- *****************************
-- TODO: create procedure for this -- instructor will call this procedure to get all registered students  
-- *****************************
/*CREATE OR REPLACE FUNCTION _add_to_course_grade()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE 
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format('INSERT INTO %I values(%L, %L);', 'grade_'||NEW.course_id||'_'||temp_semester||'_'||temp_year, NEW.student_id, NULL);
    return NULL;
END;
$$;*/
/*
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
*/
/*CREATE TRIGGER add_to_course_grade
AFTER INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _add_to_course_grade();*/


-- *********************************************************************************************



-- trigger to create new student registration and course_offering table when update happens in current_sem_and_year table
CREATE OR REPLACE FUNCTION _create_course_offering_student_registration()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE 
temp_student_id char(11);
temp_ins_id integer;
temp_batch_adviser record;
temp_batch_adviser_2 integer;
BEGIN
    EXECUTE format('CREATE TABLE %I (
        course_id CHAR(5) NOT NULL PRIMARY KEY,
        ins_id INTEGER NOT NULL,
        ins_id2 INTEGER,
        ins_id3 INTEGER,
        cgpa_criterion numeric,
        maxCapacity INTEGER,
        timetable_slot varchar(10) NOT NULL,
        all_dept BOOLEAN NOT NULL,
        all_year BOOLEAN NOT NULL,
        dept1 varchar(5),
        dept2 varchar(5),
        dept3 varchar(5),
        year1 INTEGER,
        year2 INTEGER,
        year3 INTEGER,
        FOREIGN KEY(course_id) REFERENCES Course_Catalog(course_id),
        FOREIGN KEY(ins_id) REFERENCES Instructor(ins_id),
        FOREIGN KEY(ins_id2) REFERENCES Instructor(ins_id),
        FOREIGN KEY(ins_id3) REFERENCES Instructor(ins_id),
        FOREIGN KEY(timetable_slot) REFERENCES Timetable_slot_list(timetable_slot)
    );', 'course_offering'||'_'||NEW.semester||'_'||NEW.year);
    EXECUTE format('CREATE TABLE %I(
        section_id INTEGER NOT NULL,
        course_id CHAR(5) NOT NULL,
        ins_id INTEGER NOT NULL,
        classroom char(5) NOT NULL,
        PRIMARY KEY(section_id, course_id),
        FOREIGN KEY(course_id) REFERENCES %I(course_id),
        FOREIGN KEY(ins_id) REFERENCES Instructor(ins_id)
    );', 'section'||'_'||NEW.semester||'_'||NEW.year, 'course_offering'||'_'||NEW.semester||'_'||NEW.year);
    EXECUTE format('CREATE TABLE %I (
        student_id char(11),
        course_id char(5) NOT NULL,
        section_id INTEGER NOT NULL,
        FOREIGN KEY(student_id) REFERENCES Student(student_id),
        FOREIGN KEY(course_id, section_id) REFERENCES %I(course_id, section_id),
        PRIMARY KEY(student_id, course_id)
    );', 'student_registration'||'_'||NEW.semester||'_'||NEW.year, 'section'||'_'||NEW.semester||'_'||NEW.year);

    FOR temp_student_id in select student_id from student LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'course_offering'||'_'||NEW.semester||'_'||NEW.year, temp_student_id);
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'section'||'_'||NEW.semester||'_'||NEW.year, temp_student_id);
        EXECUTE format('GRANT SELECT, INSERT ON %I TO %I;', 'student_registration'||'_'||NEW.semester||'_'||NEW.year, temp_student_id);
    END LOOP;

    FOR temp_ins_id in select ins_id from instructor LOOP 
        EXECUTE format('GRANT SELECT, INSERT ON %I TO %I;', 'course_offering'||'_'||NEW.semester||'_'||NEW.year, 'instructor_'||temp_ins_id);
        EXECUTE format('GRANT SELECT, INSERT ON %I TO %I;', 'section'||'_'||NEW.semester||'_'||NEW.year, 'instructor_'||temp_ins_id);
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'student_registration'||'_'||NEW.semester||'_'||NEW.year, 'instructor_'||temp_ins_id);
    END LOOP;

    FOR temp_batch_adviser in select * from batch_adviser LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'course_offering'||'_'||NEW.semester||'_'||NEW.year, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'section'||'_'||NEW.semester||'_'||NEW.year, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'student_registration'||'_'||NEW.semester||'_'||NEW.year, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
    END LOOP;

    Delete from timetable_slot_list;

    FOR temp_student_id in select student_id from student LOOP 
        EXECUTE format('DELETE from %I;', 'ticket_student_'||temp_student_id);
    END LOOP;

    FOR temp_ins_id in select ins_id from instructor LOOP 
        EXECUTE format('DELETE from %I;', 'ticket_instructor_'||temp_ins_id);
    END LOOP;

    FOR temp_batch_adviser_2 in select ins_id from batch_adviser LOOP 
        EXECUTE format('DELETE from %I;', 'ticket_batch_adviser_'||temp_batch_adviser_2);
    END LOOP;

    DELETE from tickets_dean;

    -- triggers on student registration
    -- trigger for checking valid user
    EXECUTE format('CREATE TRIGGER a_check_valid_user
    Before INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE a_check_valid_user();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for timetable_slot checking
    EXECUTE format('CREATE TRIGGER course_in_timetable_slot
    Before INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE check_course_in_timetable_slot();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for credit limit
    EXECUTE format('CREATE TRIGGER z_credit_limit_trigger
    Before INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE z_check_credit_limit();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for pre-requisites
    EXECUTE format('CREATE TRIGGER check_prerequisites
    BEFORE INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _check_prerequisites();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    EXECUTE format('CREATE TRIGGER check_course_id_Not_Elligible
    BEFORE INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _check_course_id_Not_Elligible();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for branchAndYear
    EXECUTE format('CREATE TRIGGER check_batchAndYear
    BEFORE INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _check_batchAndYear();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for cgpa checking
    EXECUTE format('CREATE TRIGGER check_cgpa
    BEFORE INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _check_cgpa();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger for checking capacity
    EXECUTE format('CREATE TRIGGER check_capacity
    BEFORE INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _check_capacity();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    -- trigger so that whenever a student registers, a new entry is created in course grade table
    /*EXECUTE format('CREATE TRIGGER add_to_course_grade
    AFTER INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE _add_to_course_grade();', 'student_registration'||'_'||NEW.semester||'_'||NEW.year);
    */
    -- triggers on course_offerings
    -- trigger to make course grade table
    EXECUTE format('CREATE TRIGGER course_grade_table
    AFTER INSERT
    ON %I
    FOR EACH ROW
    EXECUTE PROCEDURE create_course_grade_table();', 'course_offering'||'_'||NEW.semester||'_'||NEW.year);
    return NULL;
END;
$$;

CREATE TRIGGER create_course_offering_student_registration
AFTER UPDATE
ON current_sem_and_year
FOR EACH ROW
EXECUTE PROCEDURE _create_course_offering_student_registration();
