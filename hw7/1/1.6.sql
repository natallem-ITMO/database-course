delete
from Students
where StudentId in (
    select StudentId
    from Students,
         Plan
    where Students.GroupId = Plan.GroupId
      and not exists(
            select Mark
            from Marks
            where Students.StudentId = Marks.StudentId
              and Plan.CourseId = Marks.CourseId
        ))