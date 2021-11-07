update Marks
set Mark = (select nm.Mark
            from NewMarks nm
            where Marks.StudentId = nm.StudentId
              and Marks.CourseId = nm.CourseId)
where exists(select 1
             from NewMarks nm
                      left join Marks m on m.CourseId = nm.CourseId and m.StudentId = nm.StudentId
             where Marks.StudentId = nm.StudentId
               and Marks.CourseId = nm.CourseId
               and nm.Mark is not null
               and m.Mark is not null
               and m.Mark < nm.Mark
          )