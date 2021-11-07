update Students
set Debts = (select count(distinct p.CourseId)
             from Students s
                      natural join
                  Plan p
                      left join
                  Marks m
                  on m.StudentId = s.StudentId
                      and p.CourseId = m.CourseId
             where s.StudentId = Students.StudentId
               and m.Mark is null),
    Marks =
        (select count(*)
         from Marks
         where Marks.StudentId = Students.StudentId)