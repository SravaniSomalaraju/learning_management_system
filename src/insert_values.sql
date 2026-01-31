select * from lms.Users;
select * from lms.Courses;
select * from lms.Lessons;
select * from lms.Enrollments;
select * from lms.Assesments;
select * from lms.UserActivity;
select * from lms.AssesmentSubmissions;

--insert values for users
BULK INSERT lms.Users
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\Users.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values for courses
BULK INSERT lms.Courses
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\Courses.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values for lessons
BULK INSERT lms.Lessons
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\Lessons.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values for enrollments
BULK INSERT lms.Enrollments
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\Enrollments.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values for assesments
BULK INSERT lms.Assesments
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\Assessments.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values fpr useractivity
BULK INSERT lms.UserActivity
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\UserActivity.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

--insert values for assesmentsubmissions
BULK INSERT lms.AssesmentSubmissions
FROM "C:\Users\somal\OneDrive\Desktop\lms_dataset\AssessmentSubmissions.csv"
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
