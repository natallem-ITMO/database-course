select StudentName,
       CourseName
from Courses,
     Students,
     (select distinct StudentId, CourseId
      from Students,
           Plan
      where Students.GroupId = Plan.GroupId
        and exists(
              select Mark
              from Marks
              where Students.StudentId = Marks.StudentId
                and Plan.CourseId = Marks.CourseId
                and Marks.Mark <= 2
          )) s
where s.StudentId = Students.StudentId
  and s.CourseId = Courses.CourseId