--Data Integrity and Constraints

/*
26.Propose constraints to ensure a user cannot submit the same assessment more than once

--Prevent a user from submitting the same assessment more than once
*/
ALTER TABLE lms.AssesmentSubmissions
ADD CONSTRAINT UQ_User_Assessment
UNIQUE (user_id, assesment_id);


/*
27.Ensure that assessment scores do not exceed the defined maximum score.

--Ensure scores do not exceed the maximum score
*/
ALTER TABLE lms.AssesmentSubmissions
ADD CONSTRAINT CK_Score_Limit
CHECK (score <= max_score AND score >= 0);

/*
28.Prevent users from enrolling in courses that have no lessons.
--Prevent Enrollment in Courses with No Lessons
*/

CREATE TRIGGER trg_Prevent_EmptyCourse_Enrollment
ON lms.Enrollments
INSTEAD OF INSERT
AS
BEGIN
    -- Check if the course has at least one lesson
    IF NOT EXISTS (
        SELECT 1
        FROM lms.Lessons l
        JOIN inserted i
            ON l.course_id = i.course_id
    )
    BEGIN
        RAISERROR('Cannot enroll in a course with no lessons', 16, 1);
        RETURN;
    END

    -- If lesson exists, allow insert
    INSERT INTO lms.Enrollments (user_id, course_id)
    SELECT user_id, course_id
    FROM inserted;
END;



/*
29.Ensure that only instructors can create courses.
*/
CREATE TRIGGER trg_OnlyInstructor_CreateCourse
ON lms.Courses
INSTEAD OF INSERT
AS
BEGIN
    -- Check if the user is an instructor
    IF NOT EXISTS (
        SELECT 1
        FROM lms.Users u
        JOIN inserted i
            ON u.user_id = i.instructor_id
        WHERE u.role = 'Instructor'
    )
    BEGIN
        RAISERROR('Only instructors can create courses', 16, 1);
        RETURN;
    END

    -- If instructor, allow insert
    INSERT INTO lms.Courses (course_name, instructor_id)
    SELECT course_name, instructor_id
    FROM inserted;
END;




/*
30.Describe a safe strategy for deleting courses while preserving historical data.
--Instead of deleting the course row, this marks it inactive. All enrollments, submissions, and reports remain intact for history and auditing.
--is_active is a status flag for a course.
*/
ALTER TABLE lms.Courses
ADD is_active BIT NOT NULL DEFAULT 1;


