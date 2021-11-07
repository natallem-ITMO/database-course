select distinct GroupId, CourseId
from Courses,
     Groups
where not exists(
        select GroupId, CourseId
        from (select distinct StudentId, GroupId, CourseId
              from Students,
                   Courses
              where not exists(
                      select StudentId, CourseId
                      from Marks
                      where Marks.CourseId = Courses.CourseId
                        and Marks.StudentId = Students.StudentId
                  )
             ) s
        where Courses.CourseId = s.CourseId
          and Groups.GroupId = s.GroupId
    )
