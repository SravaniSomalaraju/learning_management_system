--SECTION 2:Advanced SQL and Analytics

SELECT * FROM lms.Users;
SELECT * FROM lms.Courses;
SELECT * FROM lms.Lessons;
SELECT * FROM lms.Enrollments;
SELECT * FROM lms.Assesments;
SELECT * FROM lms.UserActivity;
SELECT * FROM lms.AssesmentSubmissions;

/* 11.For each course, calculate:
  Total number of enrolled users
  Total number of lessons
  Average lesson duration*/

SELECT
	c.course_id,
	c.course_name,
	COUNT(e.user_id) AS total_users,
	COUNT(l.lesson_id) AS total_lessons,
	AVG(l.duration_minutes) AS avg_time
FROM lms.Courses c
LEFT JOIN lms.Enrollments e
	ON c.course_id = e.course_id
LEFT JOIN lms.Lessons l
	ON c.course_id = l.course_id
GROUP BY
	c.course_id,
	c.course_name

--12.Identify the top three most active users based on total activity count.
SELECT TOP 3
	u.user_id,
	u.full_name,
	COUNT(ua.activity_id) AS total_activity_count
FROM lms.Users u
LEFT JOIN lms.UserActivity ua
	ON u.user_id = ua.user_id
WHERE ua.status = 'active'
GROUP BY
	u.user_id,
	u.full_name
ORDER BY total_activity_count DESC;


--13.Calculate course completion percentage per user based on lesson activity
SELECT
	u.user_id,
	u.full_name,
	c.course_id,
	c.course_name,
	COUNT(CASE 
			WHEN ua.status = 'active'
			THEN ua.lesson_id
			END) AS active_lessons,
	COUNT(l.lesson_id) AS total_lessons,
	CAST( 100.0 *
			COUNT(CASE
					WHEN ua.status = 'active'
					THEN ua.lesson_id
					END) /
					NULLIF(COUNT(l.lesson_id),0) AS DECIMAL(5, 2)) AS completion_percentage
FROM lms.Users u
JOIN lms.Enrollments e
	ON u.user_id = e.user_id
JOIN lms.Courses c
    ON e.course_id = c.course_id
JOIN lms.Lessons l
    ON c.course_id = l.course_id
LEFT JOIN lms.UserActivity ua
    ON u.user_id = ua.user_id
   AND l.lesson_id = ua.lesson_id   
GROUP BY
    u.user_id,
    u.full_name,
    c.course_id,
    c.course_name


--14.Find users whose average assessment score is higher than the course average.
WITH CourseAvg AS (
    SELECT
        a.course_id,
        AVG(s.score) AS course_avg_score
    FROM lms.AssesmentSubmissions s
    JOIN lms.Assesments a
        ON s.assesment_id = a.assesment_id
    GROUP BY
        a.course_id
),
UserAvg AS (
    SELECT
        u.user_id,
        u.full_name,
        a.course_id,
        AVG(s.score) AS user_avg_score
    FROM lms.Users u
    JOIN lms.AssesmentSubmissions s
        ON u.user_id = s.user_id
    JOIN lms.Assesments a
        ON s.assesment_id = a.assesment_id
    GROUP BY
        u.user_id,
        u.full_name,
        a.course_id
)
SELECT
    ua.user_id,
    ua.full_name,
    c.course_name,
    ua.user_avg_score,
    ca.course_avg_score
FROM UserAvg ua
JOIN CourseAvg ca
    ON ua.course_id = ca.course_id
JOIN lms.Courses c
    ON ua.course_id = c.course_id
WHERE
    ua.user_avg_score > ca.course_avg_score
ORDER BY
    c.course_name,
    ua.user_avg_score DESC;


--15.List courses where lessons are frequently accessed but assessments are never attempted.
SELECT
	c.course_id,
	c.course_name
FROM lms.Courses c
JOIN lms.Lessons l
	ON c.course_id = l.course_id
JOIN lms.UserActivity ua
	ON l.lesson_id = ua.lesson_id
WHERE ua.status = 'active'
AND NOT EXISTS (
	SELECT 1
	FROM lms.Assesments a
	JOIN lms.AssesmentSubmissions s
	ON a.assesment_id = s.assesment_id
	WHERE a.course_id = c.course_id
);


--16.Rank users within each course based on their total assessment score.
SELECT
	u.user_id,
	u.full_name,
	c.course_id,
	c.course_name,
	SUM(score) AS total_score,

	DENSE_RANK() OVER ( PARTITION BY c.course_id ORDER BY SUM(s.score) DESC) AS course_rank
FROM lms.Users u
JOIN lms.AssesmentSubmissions s
	ON u.user_id = s.user_id
JOIN lms.Assesments a
	ON a.assesment_id = s.assesment_id
JOIN lms.Courses c
	ON a.course_id = c.course_id
GROUP BY
    u.user_id,
    u.full_name,
    c.course_id,
    c.course_name;


--17.Identify the first lesson accessed by each user for every course.
WITH RankedLessons AS (
    SELECT
        u.user_id,
        u.full_name,
        c.course_id,
        c.course_name,
        l.lesson_id,
        l.lesson_title,
        ua.activity_time,

        ROW_NUMBER() OVER (
            PARTITION BY u.user_id, c.course_id
            ORDER BY ua.activity_time ASC
        ) AS rn
    FROM lms.Users u
    JOIN lms.UserActivity ua
        ON u.user_id = ua.user_id
    JOIN lms.Lessons l
        ON ua.lesson_id = l.lesson_id
    JOIN lms.Courses c
        ON l.course_id = c.course_id
)
SELECT
    user_id,
    full_name,
    course_name,
    lesson_title,
    activity_time AS first_access_time
FROM RankedLessons
WHERE rn = 1
ORDER BY
    user_id,
    course_name;


--18.Find users with activity recorded on at least five consecutive days.
WITH ActivityDates AS (
    SELECT DISTINCT
        ua.user_id,
        CAST(ua.activity_time AS DATE) AS activity_date
    FROM lms.UserActivity ua
),
Streaks AS (
    SELECT
        user_id,
        activity_date,
        DATEADD(DAY,
            -ROW_NUMBER() OVER (
                PARTITION BY user_id
                ORDER BY activity_date
            ),
            activity_date
        ) AS streak_group
    FROM ActivityDates
)
SELECT DISTINCT
    u.user_id,
    u.full_name
FROM Streaks s
JOIN lms.Users u
    ON s.user_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name,
    s.streak_group
HAVING
    COUNT(*) >= 5;


--19.Retrieve users who enrolled in a course but never submitted any assessment.
SELECT DISTINCT
    u.user_id,
    u.full_name
FROM lms.Users u
JOIN lms.Enrollments e
    ON u.user_id = e.user_id
LEFT JOIN lms.AssesmentSubmissions s
    ON u.user_id = s.user_id
WHERE s.user_id IS NULL;


--20.List courses where every enrolled user has submitted at least one assessment.
SELECT
    c.course_id,
    c.course_name
FROM lms.Courses c
JOIN lms.Enrollments e
    ON c.course_id = e.course_id
LEFT JOIN lms.Assesments a
    ON c.course_id = a.course_id
LEFT JOIN lms.AssesmentSubmissions s
    ON a.assesment_id = s.assesment_id
   AND s.user_id = e.user_id
GROUP BY
    c.course_id,
    c.course_name
HAVING
    COUNT(DISTINCT e.user_id) = COUNT(DISTINCT s.user_id);
