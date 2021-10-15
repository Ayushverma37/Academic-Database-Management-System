CREATE TABLE Instructor(
      ins_id INTEGER NOT NULL PRIMARY KEY,
      first_name VARCHAR(10) NOT NULL,
      last_name VARCHAR(10) NOT NULL,
      dept_name VARCHAR(10) NOT NULL
);

CREATE TABLE Student(
      student_id INTEGER NOT NULL PRIMARY KEY,
      first_name VARCHAR(10) NOT NULL,
      last_name VARCHAR(10) NOT NULL,
      dept_name VARCHAR(10) NOT NULL
);

CREATE TABLE Section(
      section_id INTEGER NOT NULL PRIMARY KEY,
      course_id CHAR(5) NOT NULL,
      semester INTEGER NOT NULL,
      year INTEGER NOT NULL,
      FOREIGN KEY(course_id, semester, year) REFERENCES Course_Offering(course_id, semester, year)
);

CREATE TABLE Course_Catalog (
      course_id char(5) primary key,
      L numeric NOT NULL,
      T numeric NOT NULL,
      P numeric NOT NULL,
      S numeric NOT NULL,
      C numeric NOT NULL
);

CREATE TABLE Course_Offering (
      course_id char(5) primary key,
      semester int NOT NULL,
      year int NOT NULL,
      cgpa_criterion numeric NOT NULL,
      maxCapacity int NOT NULL,
      course_id_Not_Elligible char(5) NOT NULL ,
      ins_id1 int NOT NULL,
      ins_id2 int NOT NULL,
      ins_id3 int NOT NULL,
      timetable_slot varchar(10) NOT NULL,
      branch1 char(5),
      branch2 char(5),
      branch3 char(5),
      FOREIGN KEY(course_id) REFERENCES Course_Catalog(course_id),
      FOREIGN KEY(course_id_Not_Elligible) REFERENCES Course_Catalog(course_id),
      FOREIGN KEY(ins_id1) REFERENCES Instructor(ins_id),
      FOREIGN KEY(ins_id2) REFERENCES Instructor(ins_id),
      FOREIGN KEY(ins_id3) REFERENCES Instructor(ins_id),
);

-- different table for containing all timetable slots?
-- section kaise allot hoga to student ?
-- section_id foreign key hoga in student registration ?

CREATE TABLE Student_Registration (
      student_id int primary key,
      course_id char(5) NOT NULL,
      semester int NOT NULL,
      year int NOT NULL,
      section_id NOT NULL,
      FOREIGN KEY(student_id) REFERENCES Student(student_id),
      FOREIGN KEY(course_id, semester, year) REFERENCES Course_Offering(course_id, semester, year)
);
