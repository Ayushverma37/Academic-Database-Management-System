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
BEGIN
select timetable_slot into new_course_timetable_slot from Course_Offering as CO where NEW.course_id = CO.course_id;
FOR student_registration_row in select * from Student_Registration as SR where SR.student_id = NEW.student_id
LOOP
select timetable_slot into old_course_timetable_slot from Course_Offering as CO where student_registration_row.course_id = CO.course_id;
if new_course_timetable_slot = old_course_timetable_slot then
  raise exception 'INSERTION FAILED: Course in timetable slot already exists';
end if;
END LOOP;
RETURN NEW;
END;
$$;

CREATE TRIGGER course_in_timetable_slot
Before INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE check_course_in_timetable_slot();









-- procedure to get credits registered in previous 2 semesters
-- modify if previous semester are in different year than current one
CREATE OR REPLACE FUNCTION get_registered_credits_previous_2_semester(input_student_id char(11), input_semester INTEGER, input_year INTEGER)
RETURNS NUMERIC
LANGUAGE PLPGSQL 
AS $$
DECLARE
trans_student_row record;
credit_of_previous NUMERIC;
temp NUMERIC;
BEGIN 
for trans_student_row in EXECUTE format('select * from %I', 'trans_'||input_student_id) LOOP 
if trans_student_row.semester = input_semester-1 AND trans_student_row.year = input_year THEN
select C into temp from Course_Catalog as CC where CC.course_id = trans_student_row.course_id; 
credit_of_previous := credit_of_previous + temp;
end if;
if trans_student_row.semester = input_semester-2 AND trans_student_row.year = input_year THEN
select C into temp from Course_Catalog as CC where CC.course_id = trans_student_row.course_id; 
credit_of_previous := credit_of_previous + temp;
end if;
END LOOP;
return credit_of_previous;
END;
$$;

-- procedure to get credits registered in this semester
CREATE OR REPLACE FUNCTION get_credits_registered_in_this_sem(input_student_id char(11), input_semester INTEGER, input_year INTEGER)
RETURNS NUMERIC 
LANGUAGE PLPGSQL 
AS $$
DECLARE
registration_row record;
credits_current NUMERIC;
temp NUMERIC;
BEGIN 
for registration_row in select * from Student_Registration as SR where SR.student_id = input_student_id AND SR.semester = input_semester AND SR.year = input_year LOOP
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
CREATE OR REPLACE FUNCTION check_credit_limit()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
credits_registered numeric;
max_credits_allowed numeric;
credits_in_this_sem numeric;
credits_for_new_course numeric;
BEGIN
credits_registered := get_registered_credits_previous_2_semester(NEW.student_id, NEW.semester, NEW.year);
max_credits_allowed := 1.25*credits_registered;
credits_in_this_sem := get_credits_registered_in_this_sem(NEW.student_id, NEW.semester, NEW.year);
select CO.c into credit_for_new_course from Course_Offering as CO where CO.course_id = NEW.course_id;
if credit_for_new_course + credits_in_this_sem > max_credits_allowed then
--ticket generation function call 
raise exception 'Credit limit exceeded, ticket generated';
end if;
END;
$$;

CREATE TRIGGER credit_limit_trigger
Before INSERT
ON Student_Registration
FOR EACH ROW 
EXECUTE PROCEDURE check_credit_limit();









-- tigger to create new table for every new entry into course offering
CREATE OR REPLACE FUNCTION create_course_grade_table()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
EXECUTE format('CREATE TABLE %I (student_id char(11) PRIMARY KEY, grade INTEGER);', 'grade_' || NEW.course_id::text || '_' || NEW.semester || '_' || NEW.year);
RETURN NULL;
END;
$$;

CREATE TRIGGER course_grade_table
AFTER INSERT
ON Course_Offering
FOR EACH ROW
EXECUTE PROCEDURE create_course_grade_table();







-- trigger to create new table for every new entry into student table
CREATE OR REPLACE FUNCTION create_trans_student_table()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, semester integer NOT NULL, year integer NOT NULL, grade INTEGER NOT NULL);', 'trans_'||NEW.student_id );
RETURN NULL;
END;
$$;

CREATE TRIGGER trans_student_grade
AFTER INSERT
ON Student
FOR EACH ROW
EXECUTE PROCEDURE create_trans_student_table();








--trigger and procedure to check if student meets the pre-requisites of the course before registering
--trigger and procedure to check if student meets the pre-requisites of the course before registering
create or replace function get_prereq (cid char(5), stud_id char(11))
returns table (course char(5),grade INTEGER)
LANGUAGE plpgsql AS $$
begin
return query EXECUTE format('select course_id, grade from %I as TS where TS.course_id=%L and TS.grade>2.0;', 'trans_'||stud_id, cid);
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
    IF prereq1<>'NULL' THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq1,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq1;
        END IF;
    END;
    END IF;
    IF prereq2<>'NULL' THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq2,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq2;
        END IF;
    END;
    END IF;
    IF prereq3<>'NULL' THEN
    BEGIN
        IF NOT EXISTS (select * from get_prereq(prereq3,NEW.student_id)) then
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq3;
        END IF;
    END;
    END IF;
    return NEW;
END;
$$;

CREATE TRIGGER check_prerequisites
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_prerequisites(); 



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
    IF curr_grade<>'NULL' then
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
BEGIN
    curr_grade:=curr_cgpa(NEW.student_id);
    select cgpa_criterion into cgpaReq from Course_Offering as CO where CO.course_id=NEW.course_id;
    IF curr_grade<cgpaReq THEN
    RAISE EXCEPTION 'cgpa of Student is less than cgpa criteria for thic course';
    END IF;
    return NEW;
END;
$$;

CREATE TRIGGER check_cgpa
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_cgpa();



--trigger and procedure to check if the course max capacity has not been achieved
--procedure to be implemented : maxCapacityOf(course_id) ____ done
CREATE OR REPLACE FUNCTION maxCapacityOf(input_course_id char(5), input_semester INTEGER, input_year INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
cap INTEGER:=0;
registration_row record;
BEGIN
    select count(*) into cap from Student_Registration as SR where SR.course_id=input_course_id AND SR.semester = input_semester AND SR.year = input_year;
    return cap; 
END;
$$;

CREATE OR REPLACE FUNCTION _check_capacity()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
courseCapacity integer;
currentCapacity integer;
BEGIN
    currentCapacity:=maxCapacityOf(NEW.course_id,NEW.semester, NEW.year);
    select maxCapacity into courseCapacity from Course_Offering as CO where CO.course_id=NEW.course_id;
    IF currentCapacity>=courseCapacity THEN
    RAISE EXCEPTION 'Course Capacity has already been reached for % course',NEW.course_id;
    END IF;
    return NEW;
END;
$$;

CREATE TRIGGER check_capacity
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_capacity();





