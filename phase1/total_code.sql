-- this file contains the total code of the project
-- order of files are:
-- create_table.sql
-- triggers_related_procedures.sql
-- stored_procedures.sql 
-- ticket.sql 
-- permissions.sql 

-- Tables created

-- Table for current_sem and year
CREATE TABLE current_sem_and_year(
      semester INTEGER NOT NULL,
      year INTEGER NOT NULL,
      PRIMARY KEY(semester, year)
);

-- Table of all instructors for an institute
CREATE TABLE Instructor(
      ins_id INTEGER NOT NULL PRIMARY KEY,
      first_name VARCHAR(10) NOT NULL,
      last_name VARCHAR(10) NOT NULL,
      dept_name VARCHAR(10) NOT NULL
);

-- Table of all students for an institute
CREATE TABLE Student(
      student_id char(11) NOT NULL PRIMARY KEY,
      first_name VARCHAR(10) NOT NULL,
      last_name VARCHAR(10) NOT NULL,
      dept_name VARCHAR(10) NOT NULL,
      batch INTEGER NOT NULL
);

-- Table for all batch advisors
CREATE TABLE batch_adviser (
    dept_name VARCHAR(10) NOT NULL,
    batch INTEGER NOT NULL,
    ins_id INTEGER NOT NULL,
    FOREIGN KEY (ins_id) REFERENCES Instructor(ins_id),
    PRIMARY KEY(dept_name, batch) 
);

-- Table of course catalog, contains 3 pre-requisites also
CREATE TABLE Course_Catalog (
    course_id char(5) primary key,
    L numeric NOT NULL,
    T numeric NOT NULL,
    P numeric NOT NULL,
    S numeric NOT NULL,
    C numeric NOT NULL,
    course_id1 char(5),
    course_id2 char(5),
    course_id3 char(5),
    course_id_Not_Elligible char(5)
);

-- Table for timetable slots
CREATE TABLE Timetable_slot_list(
    timetable_slot varchar(10) PRIMARY KEY
);

-- Table for course offering, course_id, semester, year are primary keys
-- should timetable slot be primary key as well ? -- No
-- should ins_id be primary key as well ? -- No
/*CREATE TABLE Course_Offering (
    course_id CHAR(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    ins_id INTEGER NOT NULL,
    cgpa_criterion numeric NOT NULL,
    maxCapacity INTEGER NOT NULL,
    course_id_Not_Elligible char(5) NOT NULL ,
    timetable_slot varchar(10) NOT NULL,
    branch1 char(5),
    branch2 char(5),
    branch3 char(5),
    FOREIGN KEY(course_id) REFERENCES Course_Catalog(course_id),
    FOREIGN KEY(course_id_Not_Elligible) REFERENCES Course_Catalog(course_id),
    FOREIGN KEY(ins_id) REFERENCES Instructor(ins_id),
    FOREIGN KEY(timetable_slot) REFERENCES Timetable_slot_list(timetable_slot),
    PRIMARY KEY(course_id, semester, year)
);*/

-- different table for containing all timetable slots?
-- how to allot section to student ? -- create a procedure
-- is section_id foreign in student registration ? -- yes

-- Table for sections
/*CREATE TABLE Section(
    section_id INTEGER NOT NULL,
    course_id CHAR(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    classroom char(5) NOT NULL,
    PRIMARY KEY(section_id, course_id, semester, year),
    FOREIGN KEY(course_id, semester, year) REFERENCES Course_Offering(course_id, semester, year)
);*/

-- Table for student registration relationship, is section_id required to be a primary key ? -- assumed no
-- because each student can be in only one section of a particular course
/*CREATE TABLE Student_Registration (
    student_id char(11),
    course_id char(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    section_id INTEGER NOT NULL,
    FOREIGN KEY(student_id) REFERENCES Student(student_id),
    FOREIGN KEY(course_id, semester, year, section_id) REFERENCES Section(course_id, semester, year, section_id),
    PRIMARY KEY(student_id, course_id, semester, year)
);*/


-- TODO: create table for tickets
-- Create templates for grades table

-- Table for tickets
-- doubt -- make a seperate table containing ticket id, course_id, semester, year or not ?
-- make diiferent ticket tables for each instructor ????
/*CREATE TABLE ticket_instructor (
    student_id char(11) NOT NULL,
    course_id char(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    PRIMARY KEY(student_id, course_id, semester, year)
);
CREATE TABLE ticket_advisor (
    student_id char(11) NOT NULL,
    course_id char(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    PRIMARY KEY(student_id, course_id, semester, year)
);
CREATE TABLE ticket_dean (
    student_id char(11) NOT NULL,
    course_id char(5) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    PRIMARY KEY(student_id, course_id, semester, year)
);*/

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
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    select batch into stud_batch from Student where NEW.student_id=Student.student_id;
    IF stud_batch<temp_year THEN
    BEGIN
        credits_registered := get_registered_credits_previous_2_semester(NEW.student_id, temp_semester, temp_year);
        max_credits_allowed := 1.25*credits_registered;
        credits_in_this_sem := get_credits_registered_in_this_sem(NEW.student_id);
        select CC.C into credits_for_new_course from Course_Catalog as CC where CC.course_id = NEW.course_id;
        if credits_for_new_course + credits_in_this_sem > max_credits_allowed then
            --ticket generation function call
            -- EXECUTE format('INSERT into %I values(%L, %L);','ticket_student_'||NEW.student_id, NEW.course_id, NULL);
            raise exception 'Credit limit exceeded';
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

-- procedure for ticket_insertion
CREATE OR REPLACE FUNCTION generate_ticket(student_id char(11), in_course_id char(5))
RETURNS VOID
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
curr_user VARCHAR(20);
user_dean VARCHAR(20); 
BEGIN
    select current_user into curr_user;
    user_dean:= 'dean';
    IF (curr_user != student_id) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to generate ticket';
    END IF;
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    credits_registered := get_registered_credits_previous_2_semester(student_id, temp_semester, temp_year);
    max_credits_allowed := 1.25*credits_registered;
    credits_in_this_sem := get_credits_registered_in_this_sem(student_id);
    select CC.C into credits_for_new_course from Course_Catalog as CC where CC.course_id = in_course_id;
    if credits_for_new_course + credits_in_this_sem > max_credits_allowed then
        EXECUTE format('INSERT into %I values(%L, %L);','ticket_student_'||student_id, in_course_id, NULL);
        raise notice 'Tickiet generated';
    end if;
END;
$$;






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
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    EXECUTE format ('select cgpa_criterion from %I as CO where CO.course_id=%L;', 'course_offering_'||temp_semester||'_'||temp_year, NEW.course_id) into cgpaReq;
    IF cgpaReq IS NOT NULL THEN
    BEGIN
        curr_grade:=curr_cgpa(NEW.student_id);
        -- select cgpa_criterion into cgpaReq from Course_Offering as CO where CO.course_id=NEW.course_id;
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
    user_dean:= 'dean';
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
    user_dean:= 'dean';
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
    user_dean:= 'dean';
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
    user_dean:= 'dean';
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
    EXECUTE format('GRANT SELECT ON %I TO %I;', 'report_of_'||in_student_id || '_'||temp_semester||'_'||temp_year, in_student_id);
    for trans_student_row in EXECUTE format('select * from %I;', 'trans_'||in_student_id) LOOP
        if trans_student_row.semester = temp_semester AND trans_student_row.year = temp_year then 
            EXECUTE format('INSERT into %I values(%L, %L);', 'report_of_'||in_student_id || '_'||temp_semester||'_'||temp_year, trans_student_row.course_id, trans_student_row.grade);
        end if;
    end LOOP;
    cgpa := curr_cgpa(in_student_id);
    return cgpa;
END;
$$;

-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- create a stored procedure get_tickets_instructor which seraches for tickets for the instructor
-- and adds them in instructor tickets table
-- create a stored procedure get_tickets_batch_advisor which searches for tickets for his batch
-- and adds them in batch table for his decision
-- create a stored procedure get_tickets_dean which searches for all tickets in batch advisor tables
-- and adds them in dean tickets table
-- finally dean conveys final confirmation to student


--STEP1: create ticket tables

-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_student_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
DECLARE
temp_ins_id integer;
temp_batch_adviser record;
BEGIN
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, approved char(3));', 'ticket_student_'||NEW.student_id);

    FOR temp_ins_id in (select ins_id from instructor) LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'instructor_'||temp_ins_id);
    END LOOP;

    FOR temp_batch_adviser in select * from batch_adviser LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
    END LOOP;
    return NEW;
END;
$$;

CREATE TRIGGER ticket_student
BEFORE INSERT 
ON Student 
FOR EACH ROW 
EXECUTE PROCEDURE create_student_ticket();

-- create trigger on instructor table that will create a new ticket table when a new instructor is added by dean
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_instructor_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (student_id char(11) NOT NULL, course_id char(5) NOT NULL, accepted char(3));', 'ticket_instructor_'||NEW.ins_id);
    return NEW;
END;
$$;

CREATE TRIGGER ticket_instructor
BEFORE INSERT 
ON Instructor 
FOR EACH ROW 
EXECUTE PROCEDURE create_instructor_ticket();

-- create trigger on batch advisor table that will create a new ticket table when a new batch advisor is added by dean
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_batch_adviser_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (student_id char(11) NOT NULL,course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_advisor char(3));', 'ticket_batch_adviser_'||NEW.ins_id);
    return NEW;
END;
$$;

CREATE TRIGGER ticket_batch_adviser
BEFORE INSERT 
ON batch_adviser
FOR EACH ROW 
EXECUTE PROCEDURE create_batch_adviser_ticket();

-- table of dean tickets
CREATE TABLE tickets_dean (student_id char(11) NOT NULL, course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_adviser char(3), final_decision char(3));

-- STEP2: filling instructor tickets table

-- search all student ticket tables for tickets of courses taught by the instructor
-- add them to instructor ticket table
CREATE OR REPLACE FUNCTION get_tickets_instructor(in_course_id char(5), in_ins_id INTEGER)
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_student_id char(11);
ticket_row record;
curr_user VARCHAR(20);
user_dean VARCHAR(20);
ins_login VARCHAR(20);
BEGIN 
    -- check if valid user is accessing the course
    select current_user into curr_user;
    user_dean:= 'dean';
    ins_login:='instructor_'||in_ins_id;
    IF (curr_user != ins_login) AND (curr_user!=user_dean) THEN
        RAISE EXCEPTION 'Invalid user attempting to get tickets';
    END IF;
    -- get all student_id
    for temp_student_id in select student_id from Student LOOP
        --access their ticket tables
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the course exists and not already checked
            if ticket_row.course_id = in_course_id AND ticket_row.approved IS NULL then
                --add row in instructor ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L);', 'ticket_instructor_'||in_ins_id, temp_student_id, ticket_row.course_id, NULL);
            end if;
        END LOOP;
    END LOOP; 
END;
$$;

-- STEP3: filling batch advisor ticket table 

-- search ticket tables of all students in his/her batch 
-- add them into batch_advisor ticket table 

CREATE OR REPLACE FUNCTION get_tickets_batch_adviser(in_ins_id INTEGER)
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_dept varchar(10);
temp_batch integer;
temp_student_id char(11);
ticket_row record;
temp_ins_id INTEGER;
temp_approved char(3);
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    -- get current semester and year
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- access batch advisor table to get dept_name and batch 
    select dept_name, batch into temp_dept, temp_batch from batch_adviser where ins_id = in_ins_id;
    -- get all students from student table in the batch and dept
    for temp_student_id in select student_id from Student where dept_name = temp_dept and batch = temp_batch LOOP 
        -- check the ticket tables of all students in the batch 
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the student is not alreday approved
            if ticket_row.approved IS NULL then
                --get instructor for the course 
                EXECUTE format ('select ins_id from %I as CO where CO.course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, ticket_row.course_id) into temp_ins_id;
                -- access ticket table of that instructor
                EXECUTE format('select accepted from %I as TI where TI.student_id = %L', 'ticket_instructor_'||temp_ins_id, temp_student_id) into temp_approved;
                --add row in batch ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L, %L);', 'ticket_batch_adviser_'||in_ins_id, temp_student_id, ticket_row.course_id, temp_approved ,NULL);
            end if;
        END LOOP; 
    END LOOP; 
END;
$$;

-- STEP4: fiiling dean ticket table 

-- all pending tickets from ticket table of all students

CREATE OR REPLACE FUNCTION get_tickets_dean()
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_ins_id INTEGER;
temp_record record;
BEGIN
    -- get all batch advisors
    for temp_ins_id in select ins_id from batch_adviser LOOP 
        -- access all rows of batch advisor ticket tables 
        for temp_record in EXECUTE format('select * from %I;', 'ticket_batch_adviser_'||temp_ins_id) LOOP 
            -- add those rows in dean ticket table 
            INSERT INTO tickets_dean values(temp_record.student_id, temp_record.course_id, temp_record.accepted_by_instructor, temp_record.accepted_by_batch_advisor, NULL);
        END LOOP;
    END LOOP;
END;
$$;

-- STEP5: conveying final decision

-- Procedure to convey final decision to student about ticket approved or not.
-- If approved -- set column of student ticket table to YES else NO.
-- Also add rows in student registration, if the ticket is approved.
CREATE OR REPLACE FUNCTION convey_final_decision()
RETURNS VOID 
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
dean_ticket_row record;
temp_semester INTEGER;
temp_year INTEGER;
temp_section INTEGER;
temp_ins_id INTEGER;
BEGIN 
    -- get values of current semester and year
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- access each row of dean tickets table 
    for dean_ticket_row in select * from tickets_dean LOOP 
        -- if final decision is decided
        if dean_ticket_row.final_decision IS NOT NULL then 
            -- update entry in student ticket table 
            EXECUTE format('UPDATE %I set approved = %L where course_id = %L;', 'ticket_student_'||dean_ticket_row.student_id, dean_ticket_row.final_decision, dean_ticket_row.course_id);
            -- check if decision is approved 
            if dean_ticket_row.final_decision = 'YES' then 
                -- get instructor for the course
                EXECUTE format('select ins_id from %I where course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, dean_ticket_row.course_id) into temp_ins_id;
                -- get a section for the course 
                EXECUTE format('select section_id from %I where course_id = %L and ins_id = %L;', 'section_'||temp_semester||'_'||temp_year, dean_ticket_row.course_id, temp_ins_id) into temp_section;
                -- add row in student registration
                EXECUTE format('DROP TRIGGER z_credit_limit_trigger on %I;', 'student_registration_'||temp_semester||'_'||temp_year);
                EXECUTE format('INSERT INTO %I values(%L, %L, %L);', 'student_registration_'||temp_semester||'_'||temp_year, dean_ticket_row.student_id, dean_ticket_row.course_id, temp_section);
                EXECUTE format('CREATE TRIGGER z_credit_limit_trigger Before INSERT ON %I FOR EACH ROW EXECUTE PROCEDURE z_check_credit_limit();', 'student_registration'||'_'||temp_semester||'_'||temp_year);
            end if;
        end if;
    END LOOP;
END;
$$;

-- trigger to create new student login
CREATE OR REPLACE FUNCTION create_new_student_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', NEW.student_id, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;' , NEW.student_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', NEW.student_id);
    EXECUTE format('GRANT SELECT,INSERT ON %I TO %I;', 'ticket_student_'||NEW.student_id, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', 'trans_'||NEW.student_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_instructor_'||NEW.ins_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_batch_adviser_'||NEW.ins_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', NEW.student_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_student_login
AFTER INSERT 
ON student 
FOR each row 
EXECUTE PROCEDURE create_new_student_login();

-- trigger to create new instructor login 
CREATE OR REPLACE FUNCTION create_new_ins_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
DECLARE
temp_student_id char(11);
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'instructor_'||NEW.ins_id, 'abc');
    EXECUTE format('GRANT pg_read_server_files TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;',  'instructor_'||NEW.ins_id);
    --EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'instructor_'||NEW.ins_id);
    FOR temp_student_id in select student_id from student LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||temp_student_id, 'instructor_'||NEW.ins_id);
    END LOOP;

    EXECUTE format('GRANT ALL ON %I TO %I;', 'ticket_instructor_'||NEW.ins_id, 'instructor_'||NEW.ins_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_batch_adviser_'||NEW.ins_id, 'instructor_'||NEW.ins_id);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', 'instructor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_ins_login
AFTER INSERT 
ON instructor
FOR each row 
EXECUTE PROCEDURE create_new_ins_login();

-- trigger to create new batch adviser login
CREATE OR REPLACE FUNCTION create_new_ba_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
DECLARE 
temp_student_id char(11);
temp_ins_id integer;
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON student TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    -- EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    FOR temp_student_id in select student_id from student LOOP
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||temp_student_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    END LOOP;

    FOR temp_ins_id in select ins_id from instructor LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_instructor_'||temp_ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    END LOOP;

    -- EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_instructor_'||NEW.ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT ALL ON %I TO %I;', 'ticket_batch_adviser_'||NEW.ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    return NULL;
END;
$$;

CREATE TRIGGER new_ba_login
AFTER INSERT 
ON batch_adviser
FOR each row 
EXECUTE PROCEDURE create_new_ba_login();
