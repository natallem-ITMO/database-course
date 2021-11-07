create view Debts as
select s.StudentId as StudentId, count(distinct p.CourseId) as Debts
from Students s
         natural join
     Plan p
         left join
     Marks m
     on m.StudentId = s.StudentId
         and p.CourseId = m.CourseId
where m.Mark is null
group by s.StudentId
