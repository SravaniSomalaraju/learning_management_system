SELECT * FROM lms.Users;
SELECT * FROM lms.Courses;
SELECT * FROM lms.Lessons;
SELECT * FROM lms.Enrollments;
SELECT * FROM lms.Assesments;
SELECT * FROM lms.UserActivity;
SELECT * FROM lms.AssesmentSubmissions;

/*
1.List all users who are enrolled in more than three courses
    why: Inner Join is used to select only users who have enrollments
    assumption: Each enrollment row represents one user enrolled in one course
    behaviour: Groups users by user_id and counts courses, then filters users with more than 3 courses
*/

SELECT 
	u.user_id,
	u.full_name,
	COUNT(e.course_id) as total_courses
FROM lms.Users u
JOIN lms.Enrollments  e
	On u.user_id = e.user_id
GROUP BY
	u.user_id,
	u.full_name
HAVING COUNT(e.course_id) > 3;


/*
2.Find courses that currently have no enrollments
    why: Left Join is used to keep all courses and check which ones have no matching enrollments
    assumption: A course with no matching row in Enrollments means no users are enrolled
    behaviour: Returns only courses where the joined enrollment is NULL
*/

SELECT
	c.course_id,
	c.course_name
FROM lms.Courses c 
LEFT JOIN lms.Enrollments e
	ON c.course_id = e.course_id
WHERE e.course_id IS NULL;


/*
3.Display each course along with the total number of enrolled users.
    why: Left Join is used to include all courses, even those with zero enrollments
    assumption: Each row in Enrollments represents one user enrolled in one course
    behaviour: Groups by course and counts enrolled users per course
*/

SELECT
	c.course_id,
	c.course_name,
	COUNT(e.user_id) AS total_enroll_users
FROM lms.Courses c
LEFT JOIN lms.Enrollments e
	ON c.course_id = e.course_id
GROUP BY
	c.course_id,
	c.course_name;


/*
4.Identify users who enrolled in a course but never accessed any lesson.
    why: Inner Join ensures only enrolled users are considered, Left Join checks for missing activity
    assumption: UserActivity contains a row for every lesson access by a user
    behaviour: Returns users who have enrollments but no matching activity records
*/

SELECT 
	u.user_id,
	u.full_name
FROM lms.Users u
JOIN lms.Enrollments e
	ON u.user_id = e.user_id
LEFT JOIN lms.UserActivity ua
	ON u.user_id = ua.user_id
WHERE ua.user_id IS NULL;


/*
5.Fetch lessons that have never been accessed by any user
    why: Left Join keeps all lessons and checks which ones have no matching activity
    assumption: Each row in UserActivity represents a lesson being accessed by a user
    behaviour: Returns only lessons where no activity record exists
*/

SELECT 
    l.lesson_id,
    l.lesson_title
FROM lms.Lessons l
LEFT JOIN lms.UserActivity ua
    ON l.lesson_id = ua.lesson_id
WHERE ua.lesson_id IS NULL;


/*
6.Show the last activity timestamp for each user
    why: Left Join is used to include users even if they have no activity
    assumption: activity_time accurately records when a user accessed a lesson
    behaviour: Groups by user and returns the latest activity time using MAX, sorted by most recent first
*/

SELECT 
    u.user_id,
    u.full_name,
    MAX(ua.activity_time) AS last_activity_time
FROM lms.Users u
LEFT JOIN lms.UserActivity ua
    ON u.user_id = ua.user_id
GROUP BY 
    u.user_id,
    u.full_name
ORDER BY 
    last_activity_time DESC;


/*
7..List users who submitted an assessment but scored less than 50 percent of the maximum score.
    why: Inner Joins are used to link submissions to users and assessments to get both score and max score
    assumption: Each submission row belongs to one valid user and one valid assessment
    behaviour: Compares each user’s score with half of the max score and returns only low-scoring submissions
*/

SELECT
	u.user_id,
	u.full_name,
	a.assesment_title,
	s.score,
	a.max_score
FROM lms.AssesmentSubmissions s
JOIN lms.Users u
	ON s.user_id = u.user_id
JOIN lms.Assesments a
	ON u.user_id = s.user_id
WHERE s.score < (a.max_score * 0.5)


/*
8.Find assessments that have not received any submissions
    why: Left Join keeps all assessments and checks which ones have no matching submissions
    assumption: Each row in AssesmentSubmissions represents one user submission for an assessment
    behaviour: Returns only assessments where no submission record exists
*/

SELECT
    a.assesment_id,
    a.assesment_title,
    a.course_id
FROM lms.Assesments a
LEFT JOIN lms.AssesmentSubmissions s
    ON a.assesment_id = s.assesment_id
WHERE s.assesment_id IS NULL;


/*
9.Display the highest score achieved for each assessment
    why: Left Join includes all assessments, even those with no submissions
    assumption: Each submission row contains a valid score for an assessment
    behaviour: Groups by assessment and returns the maximum score using MAX
*/

SELECT
    a.assesment_id,
    a.assesment_title,
    MAX(s.score) AS highest_score
FROM lms.Assesments a
LEFT JOIN lms.AssesmentSubmissions s
    ON a.assesment_id = s.assesment_id
GROUP BY
    a.assesment_id,
    a.assesment_title
ORDER BY
    a.assesment_id;


/*
10.Identify users who are enrolled in a course but have an inactive enrollment status.
    why: Inner Join links enrollments to users, and NOT EXISTS checks that no active lesson activity exists for that user in the course
    assumption: Active access to any lesson means the user is actively participating in the course
    behaviour: Returns enrolled users who have no matching active records in UserActivity for that course
*/

SELECT
    u.user_id,
    u.full_name,
    e.course_id
FROM lms.Enrollments e
JOIN lms.Users u
    ON e.user_id = u.user_id
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.UserActivity ua
    JOIN lms.Lessons l
        ON ua.lesson_id = l.lesson_id
    WHERE ua.user_id = e.user_id
      AND l.course_id = e.course_id
      AND ua.status = 'active'
);
