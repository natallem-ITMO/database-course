select distinct StudentId
from Students
where not exists(
        select StudentId
        from (select distinct Students.StudentId as StudentId
              from Marks,
                   Students,
                   Plan,
                   Lecturers
              where Students.StudentId = Marks.StudentId
                and Marks.CourseId = Plan.CourseId
                and Students.GroupId = Plan.GroupId
                and Lecturers.LecturerId = Plan.LecturerId
                and Lecturers.LecturerName = :LecturerName) k
        where k.StudentId = Students.StudentId
    )

