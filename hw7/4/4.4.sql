merge into Marks m
    using NewMarks nm
    on nm.StudentId = m.StudentId and nm.CourseId = m.CourseId
    when matched then
        update set Mark = case
                              when nm.Mark > m.Mark then nm.Mark
                              else m.Mark
            end
    when not matched then insert (StudentId, CourseId, Mark)
        values (nm.StudentId, nm.CourseId, nm.Mark)