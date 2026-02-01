--section 3 : performance and optimization

/*Suggest appropriate indexes for improving performance of:
Course dashboards
User activity analytics*/

--Total enrolled users per course
CREATE NONCLUSTERED INDEX IX_Enrollments_Course_User
ON lms.Enrollments (course_id, user_id);
GO

--Total lessons per course
CREATE NONCLUSTERED INDEX IX_Lessons_Course
ON lms.Lessons (course_id);
GO

--Finding all assessments for a course
CREATE NONCLUSTERED INDEX IX_Assesments_Course
ON lms.Assesments (course_id);
GO



--22.Identify potential performance bottlenecks in queries involving user activity.
/*The UserActivity table is typically the largest and fastest-growing table in the LMS because it stores historical interaction data such as lesson access, status changes, and timestamps.
Most analytics queries rely on this table, making it a central point of performance risk.*/


--23.Explain how you would optimize queries when the user_activity table grows to millions of rows.

/*This index optimizes:
  Last activity per user
  First lesson accessed
  Filtering by status and time ranges*/

CREATE NONCLUSTERED INDEX IX_UserActivity_User_Time
ON lms.UserActivity (user_id, activity_time)
INCLUDE (lesson_id, status);

--index on lesson based queries.

/*Analyze activity per lesson
Find users who accessed a specific lesson
Join lessons with activity data*/

CREATE NONCLUSTERED INDEX IX_UserActivity_Lesson
ON lms.UserActivity (lesson_id, user_id)
INCLUDE (activity_time, status);

--Always apply filters on UserActivity before joining to other tables
--Do not use CAST, CONVERT, or other functions on activity_time in the WHERE clause.

/*
24.Describe scenarios where materialized views would be useful for this schema.

materialized indexes would be useful in scenarios like:
--Showing total enrolled users, total lessons, and average scores per course. 
These require multiple joins and aggregations, which are expensive to calculate every time
--Precomputing completion percentages for each user per course instead of scanning UserActivity and Lessons tables repeatedly.
--Counting active users or lesson accesses per day or per course.
--Precomputing average, highest, and lowest scores per assessment for reporting.
*/


/*
25.Explain how partitioning could be applied to user_activity.
--Partitioning can be applied to the UserActivity table by splitting the data based on time, using the activity_time column.
--SQL Server scans only the relevant partition instead of the entire table.
--Each partition holds activity records for a specific time range (for example, one month).
*/


