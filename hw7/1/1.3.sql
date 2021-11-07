delete
from Students
where not exists(select 1 from Marks where Marks.StudentId = Students.StudentId)
