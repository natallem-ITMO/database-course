create view StudentMarks as
select s.StudentId as StudentId, sum(case when m.Mark is null then 0 else 1 end) as Marks
from Students s
         left join Marks m
                   on s.StudentId = m.StudentId
group by s.StudentId
