delete
from Students
where StudentId in (
    select distinct s.StudentId as StudentId
    from (select distinct Students.StudentId as StudentId, Plan.CourseId as CourseId
          from Students
                   cross join
               Plan
                   left join Marks
                             on Students.StudentId = Marks.StudentId
                                 and Marks.CourseId = Plan.CourseId
          where Students.GroupId = Plan.GroupId
            and Mark is null) s
    group by s.StudentId
    having count(s.CourseId) <= 2)
   or StudentId not in (
    select distinct Students.StudentId as StudentId
    from Students
             cross join
         Plan
             left join Marks
                       on Students.StudentId = Marks.StudentId
                           and Marks.CourseId = Plan.CourseId
    where Students.GroupId = Plan.GroupId
      and Mark is null)

