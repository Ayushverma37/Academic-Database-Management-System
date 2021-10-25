-- trigger to create new student login
CREATE OR REPLACE FUNCTION create_new_student_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', NEW.student_id, 'abc');
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
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'instructor_'||NEW.ins_id, 'abc');
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
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch, 'abc');
    return NULL;
END;
$$;

CREATE TRIGGER new_ba_login
AFTER INSERT 
ON batch_adviser
FOR each row 
EXECUTE PROCEDURE create_new_ba_login();
