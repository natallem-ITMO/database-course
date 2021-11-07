create view StudentDebts as
select a.StudentId                                         as StudentId,
       sum(case when d.CourseId is null then 0 else 1 end) as Debts
from Students a
         left join (
    select distinct s.StudentId as StudentId, p.CourseId as CourseId
    from Students s
             natural join
         Plan p
             left join
         Marks m
         on m.StudentId = s.StudentId
             and p.CourseId = m.CourseId
    where m.Mark is null
) d on d.StudentId = a.StudentId
group by a.StudentId
