-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- create a stored procedure get_tickets_instructor which seraches for tickets for the instructor
-- and adds them in instructor tickets table
-- create a stored procedure get_tickets_batch_advisor which searches for tickets for his batch
-- and adds them in batch table for his decision
-- create a stored procedure get_tickets_dean which searches for all tickets in batch advisor tables
-- and adds them in dean tickets table
-- finally dean conveys final confirmation to student

-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_student_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, approved char(3));', 'ticket_student_'||NEW.student_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_student
AFTER INSERT 
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
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, accepted char(3));', 'ticket_instructor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_instructor
AFTER INSERT 
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
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, accepted char(3));', 'ticket_batch_advisor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_batch_adviser
AFTER INSERT 
ON Instructor 
FOR EACH ROW 
EXECUTE PROCEDURE create_batch_adviser_ticket();

-- table of dean tickets
CREATE TABLE tickets_dean (course_id char(5) NOT NULL, accepted char(3));
