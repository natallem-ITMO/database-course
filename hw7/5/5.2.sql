create view AllMarks as
select Q.StudentId               as StudentId,
       Q.MarkCount + P.MarkCount as Marks
from (select s.StudentId as StudentId, sum(case when m.Mark is null then 0 else 1 end) as MarkCount
      from Students s
               left join Marks m
                         on s.StudentId = m.StudentId
      group by s.StudentId
     ) Q,
     (select s.StudentId as StudentId, sum(case when m.Mark is null then 0 else 1 end) as MarkCount
      from Students s
               left join NewMarks m
                         on s.StudentId = m.StudentId
      group by s.StudentId
     ) P
where P.StudentId = Q.StudentId