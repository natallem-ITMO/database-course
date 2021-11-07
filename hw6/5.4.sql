select distinct StudentId
from Students
where not exists(
        select distinct StudentId
        from (
                 select distinct StudentId, CourseId
                 from Plan,
                      Lecturers,
                      Students
                 where Plan.LecturerId = Lecturers.LecturerId
                   and Lecturers.LecturerName = :LecturerName
                   and Students.GroupId = Plan.GroupId
                   and not exists(
                         select Mark
                         from Marks
                         where Students.StudentId = Marks.StudentId
                           and Plan.CourseId = Marks.CourseId
                     )
             ) s
        where s.StudentId = Students.StudentId
    )