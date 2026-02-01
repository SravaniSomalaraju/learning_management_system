--Section 6: Database Design and Architecture
/*
36.Propose schema changes to support course completion certificates.
--idea:You need to store:
Who completed a course
When they completed it
Certificate ID or URL
--explanation:This table records when a user completes a course and allows the system to generate or link a certificate
*/
CREATE TABLE lms.Certificates (
    certificate_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    issued_date DATE DEFAULT GETDATE(),
    certificate_url VARCHAR(255)
);

/*
37.Describe how you would track video progress efficiently at scale.
--Idea:Don’t log every second of video — store progress checkpoints.
--Explanation:This stores only the latest position for each user and lesson, which is efficient and scalable.
*/
CREATE TABLE lms.VideoProgress (
    user_id INT,
    lesson_id INT,
    last_watched_second INT,
    updated_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, lesson_id)
);

/*
38.Discuss normalization versus denormalization trade-offs for user activity data.
--Normalized:
Data is split across:
Users
Lessons
UserActivity
--denormalized
--explanation:Normalization is good for data accuracy. Denormalization is better for fast reporting. Use both.
*/
CREATE TABLE lms.UserActivitySummary (
    user_id INT,
    course_id INT,
    activity_date DATE,
    active_count INT
);

/*
39.Design a reporting-friendly schema for analytics dashboards.
--Idea:Create summary tables or views instead of querying raw data.
--Explanation:Dashboards read from this table instead of joining 5 tables every time.
*/
CREATE TABLE lms.CourseDashboardSummary (
    course_id INT PRIMARY KEY,
    total_users INT,
    avg_score DECIMAL(5,2),
    last_updated DATETIME
);

/*
40.Explain how this schema should evolve to support millions of users.
--Key Changes:
  Partition large tables like UserActivity by date
  Add composite indexes
  Use materialized views
  Archive old data
Explanation:
This reduces table scans, improves query speed, and keeps storage manageable.
*/

