update Marks
set Mark = (select Mark
            from NewMarks nm
            where Marks.StudentId = nm.StudentId
              and Marks.CourseId = nm.CourseId
    and nm.Mark)