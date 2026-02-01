--Section 5: Transactions and Concurrency
/*
31.Design a transaction flow for enrolling a user into a course.
--Either everything succeeds or nothing is saved
--This ensures the enrollment is saved only if no error happens. If anything fails, the database rolls back.
*/
BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO lms.Enrollments (user_id, course_id)
    VALUES (1, 5);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH;


/*
32.Explain how to handle concurrent assessment submissions safely.
--Two submissions at the same time should not create duplicates.
--The UNIQUE constraint blocks duplicate submissions even if two users click submit at the same time.
*/
BEGIN TRANSACTION;

INSERT INTO lms.AssesmentSubmissions (user_id, assesment_id, score)
VALUES (1, 3, 75);

COMMIT;


/*
33.Describe how partial failures should be handled during assessment submission.
--If score insert succeeds but logging fails, nothing should be saved.
--Both inserts succeed or both fail. This keeps data consistent.
*/
CREATE TABLE lms.SubmissionLog (
    log_id INT IDENTITY PRIMARY KEY,
    user_id INT,
    assesment_id INT,
    log_time DATETIME DEFAULT GETDATE()
);

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO lms.AssesmentSubmissions (user_id, assesment_id, score)
    VALUES (1, 3, 80);

    INSERT INTO lms.SubmissionLog (user_id, assesment_id, log_time)
    VALUES (1, 3, GETDATE());

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH;


/*
34.Recommend suitable transaction isolation levels for enrollments and submissions.
--Use: Default, good performance, prevents reading uncommitted data.
*/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--Use: Reports see a stable view of data without blocking users.
--Different workloads need different balance between accuracy and performance.
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

/*
35.Explain how phantom reads could affect analytics queries and how to prevent them
--While running a report:
problem: New enrollments or submissions appear midway
Counts change during the same query
--This prevents new rows from being added while the report is running, so results stay consistent.
*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;
SELECT COUNT(*) FROM lms.Enrollments;
COMMIT;

