CREATE DATABASE LMSDB;
USE LMSDB;

CREATE SCHEMA lms;

CREATE TABLE lms.Users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL
        CHECK (role IN ('Student', 'Instructor'))
);

CREATE TABLE lms.Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id)
        REFERENCES lms.Users(user_id)
);

CREATE TABLE lms.Lessons (
    lesson_id INT PRIMARY KEY,
    course_id INT NOT NULL,
    lesson_title VARCHAR(150) NOT NULL,
    duration_minutes INT CHECK (duration_minutes > 0),
    FOREIGN KEY (course_id)
        REFERENCES lms.Courses(course_id)
);


CREATE TABLE lms.Enrollments (
    enrollment_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    UNIQUE (user_id, course_id),
    FOREIGN KEY (user_id)
        REFERENCES lms.Users(user_id),
    FOREIGN KEY (course_id)
        REFERENCES lms.Courses(course_id)
);


CREATE TABLE lms.Assesments (
    assesment_id INT PRIMARY KEY,
    course_id INT NOT NULL,
    assesment_title VARCHAR(150) NOT NULL,
    max_score INT DEFAULT 100 CHECK (max_score > 0),
    FOREIGN KEY (course_id)
        REFERENCES lms.Courses(course_id)
);

CREATE TABLE lms.UserActivity (
    activity_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    lesson_id INT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('active', 'inactive')),
    activity_time DATETIME NOT NULL,
    UNIQUE (user_id, lesson_id),
    FOREIGN KEY (user_id)
        REFERENCES lms.Users(user_id),
    FOREIGN KEY (lesson_id)
        REFERENCES lms.Lessons(lesson_id)
);


CREATE TABLE lms.AssesmentSubmissions (
    submission_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    assesment_id INT NOT NULL,
    score INT CHECK (score >= 0),
    UNIQUE (user_id, assesment_id),
    FOREIGN KEY (user_id)
        REFERENCES lms.Users(user_id),
    FOREIGN KEY (assesment_id)
        REFERENCES lms.Assesments(assesment_id)
);


select* from lms.Users;
select * from lms.Courses;
select * from lms.Lessons;
select * from lms.Enrollments;
select * from lms.Assesments;
select * from lms.UserActivity;
select * from lms.AssesmentSubmissions;