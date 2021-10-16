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


