select StudentName,
       CourseName
from Courses,
     Students,
     (select StudentId, CourseId
      from Students,
           Plan
      where Students.GroupId = Plan.GroupId
        and not exists(
              select Mark
              from Marks
              where Students.StudentId = Marks.StudentId
                and Plan.CourseId = Marks.CourseId
                and Marks.Mark > 2
          )
      union
      select StudentId, CourseId
      from Students,
           Plan
      where Students.GroupId = Plan.GroupId
        and not exists(
              select Mark
              from Marks
              where Students.StudentId = Marks.StudentId
                and Plan.CourseId = Marks.CourseId
          )) s
where s.StudentId = Students.StudentId
  and s.CourseId = Courses.CourseId