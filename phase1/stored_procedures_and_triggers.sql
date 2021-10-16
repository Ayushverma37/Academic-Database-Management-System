-- implementation of stores procedures and triggers

--trigger and procedure to check if student meets the cgpa criteria of the course before regiestering
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
CREATE OR REPLACE FUNCTION _check_capacity()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
courseCapacity integer;
currentCapacity integer;

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


