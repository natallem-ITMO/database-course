-- Хотим получить средний балл студентов 4 курса. При условии,
-- что номер курса зашит в номер группы (как было раньше).
select StudentName, avg(cast(Mark as float))
from Groups
         natural join Students
         natural join Marks
where GroupName like 'M34%'
group by StudentName

-- Используем дерево, т.к. создаем поиск по префиксу.
-- Т.к. имя >> Id, то оптимизируем индекс, сделав его покрывающим
create unique index groups_group_name_group_id_index on Groups using btree (GroupName, GroupId)

-- Хотим узнать, сколько преподавателей преподает у групп
-- (полезно например при покупке подарков от группы)
select GroupName, count(LecturerId)
from Groups
         left join Plan
                   on Groups.GroupId = Plan.GroupId
group by GroupName, Groups.GroupId

-- Используем дерево, т.к. суммирование лучше осуществлять по дереву
create index plan_group_id_lecturer_id_index on Plan using Btree (GroupId, LecturerId)

-- Хотим получить оценки по предмету 'Базы данных' тех студентов,
-- которые имеют хотя бы одну хорошую оценку (4 или 5)
select m.StudentId as StudentId, Mark
from (select StudentId
      from Marks
      where Mark >= 4) m
         natural join Marks
         natural join Courses
where CourseName = 'Базы данных'

-- Используем дерево, т.к. запрос осуществляет сравнение оценки,
-- оптимизируем индекс, сделав его покрывающим
create index marks_mark_student_id_index on Marks using btree (Mark, StudentId)