select avg(cast(Mark as float))
from Groups
    natural join Students
    natural join Marks
    natural join Courses
where GroupName = :GroupName
and CourseName = :CourseName
group by Courses.CourseId

-- Используем хеш индексы в двух индексах ниже т.к. не осуществляем поиск по префиксу, а хеш индекс эффективнее по памяти и времени
create index courses_course_name_index on Courses using hash (CourseName)
create index groups_group_name_index on Groups using hash (GroupName)
-- Используем хеш индекс т.к. не осуществляем операций подсчета значений по индексам, для большей эффективности
create index students_group_id_index on Students using hash (GroupId)
-- Связывающий Students & Courses индекс (упорядоченный)
create index marks_course_id_student_id_index on Marks using btree (CourseId, StudentId)
