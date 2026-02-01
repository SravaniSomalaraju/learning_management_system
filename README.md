                         LMS Database Project (MS SQL Server)
Project Overview:

This project implements a Learning Management System (LMS) database using Microsoft SQL Server. The schema manages users, courses, lessons, and assessments while supporting analytics, performance optimization, and strong data integrity. It is designed to scale for high user activity and reporting workloads.


Table Description:

-->Users - Stores all platform users, including students and instructors, and defines their roles and identities.

-->Courses - Stores course information and ownership by instructors.

-->Lessons - Represents learning units that belong to courses.

 -->Enrollments - Links users to the courses they are enrolled in, enabling tracking of course participation.

-->UserActivity - Records user interactions with lessons, including access status and timestamps for engagement analytics.

-->Assessments - Stores assessments associated with courses.

-->AssessmentSubmissions - Stores user submissions and scores for assessments.


Table Entity Relationships:

Users ↔ Courses
    Type: Many-to-Many
    Users can enroll in multiple courses, and each course can have multiple users. This relationship is implemented through the Enrollments table.

Courses ↔ Lessons
    Type: One-to-Many
    Each course can contain multiple lessons, while each lesson belongs to a single course.

Courses ↔ Assessments
    Type: One-to-Many
    Each course can contain multiple assessments, while each assessment belongs to a single course.

Users ↔ Lessons
    Type: Many-to-Many
    Users can access many lessons, and each lesson can be accessed by many users. This interaction is tracked using the UserActivity table.

Users ↔ Assessments
    Type: Many-to-Many
    Users can submit multiple assessments, and each assessment can be submitted by many users. This relationship is tracked using the AssesmentSubmissions table.