delete
from Students
where StudentId in (
    select StudentId
    from Marks
    group by StudentId
    having count(Mark) <= 3
)
or not exists(select 1 from Marks where Marks.StudentId = Students.StudentId)