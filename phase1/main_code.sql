-- Tables created
--                List of relations
-- Schema |         Name         | Type  |  Owner
----------+----------------------+-------+----------
-- public | course_catalog       | table | postgres
-- public | course_offering      | table | postgres
-- public | instructor           | table | postgres
-- public | section              | table | postgres
-- public | student              | table | postgres
-- public | student_registration | table | postgres
-- public | timetable_slot_list  | table | postgres
--(7 rows)


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
    course_id3 char(5)
);

-- Table for timetable slots
CREATE TABLE Timetable_slot_list(
    timetable_slot char(5) PRIMARY KEY
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
CREATE TABLE ticket_instructor (
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
);
