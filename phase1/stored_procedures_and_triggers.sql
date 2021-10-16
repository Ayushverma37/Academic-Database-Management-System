-- implementation of stores procedures and triggers

--trigger and procedure to check if student meets the cgpa criteria of the course before registering
--procedure to be implemented : gradeOf(student_id)
CREATE OR REPLACE FUNCTION _check_cgpa()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
curr_grade numeric;
cgpaReq numeric;
BEGIN
    curr_grade:=gradeOf(NEW.student_id);
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
--procedure to be implemented : maxCapacityOf(course_id)
CREATE OR REPLACE FUNCTION _check_capacity()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
courseCapacity integer;
currentCapacity integer;
BEGIN
    currentCapacity:=maxCapacityOf(NEW.course_id);
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





--trigger and procedure to ensure that a student takes only 1 course in a timetable slot
CREATE OR REPLACE FUNCTION check_course_in_timetable_slot()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
student_registration_row record;
BEGIN
FOR student_registration_row select * from Student_Registration where student_id = NEW.student_id
LOOP
if NEW.timetable_slot = student_registration_row.timetable_slot then
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
credits_registered := get_registered_credits_previous_2_semester(NEW.student_id);
max_credits_allowed := 1.25*credits_registered;
credits_in_this_sem := get_credits_registered_in_this_sem(NEW.student_id);
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
EXECUTE format('CREATE TABLE %I (student_id char(11) PRIMARY KEY, grade char(1));', 'Grade_' || NEW.course_id::text || '_' || NEW.semester || '_' || NEW.year);
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
EXECUTE format('CREATE TABLE %I (course_id, semester, year, grade);', 'Trans_'||NEW.student_id );
END;
$$;

CREATE TRIGGER trans_student_grade
AFTER INSERT
ON Student
FOR EACH ROW
EXECUTE PROCEDURE create_trans_student_table();



--trigger and procedure to check if student meets the pre-requisites of the course before registering
CREATE OR REPLACE FUNCTION _check_prerequisites()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
prereq1 char(5);
prereq2 char(5);
prereq3 char(5);
BEGIN
    select course_id1, course_id2, course_id3 into prereq1, prereq2, prereq3 from Course_Catalog as CC where CC.course.id=NEW.course_id;
    IF prereq1<>'NULL' THEN
        IF NOT EXISTS (select * from trans_student_id as TS where prereq1=TS.course_id and TS.grade>2.0)
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq1;
        END IF;
    IF prereq2<>'NULL' THEN
        IF NOT EXISTS (select * from trans_student_id as TS where prereq2=TS.course_id and TS.grade>2.0)
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq2;
        END IF;
    IF prereq3<>'NULL' THEN
        IF NOT EXISTS (select * from trans_student_id as TS where prereq3=TS.course_id and TS.grade>2.0)
        RAISE EXCEPTION 'pre-requisite % not met by student',prereq3;
        END IF;
    END IF;
    return NEW;
END;
$$;

CREATE TRIGGER check_prerequisites
BEFORE INSERT
ON Student_Registration
FOR EACH ROW
EXECUTE PROCEDURE _check_prerequisites();