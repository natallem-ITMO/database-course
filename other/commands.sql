SET CLIENT_ENCODING TO 'utf8';
create database ctd with ENCODING 'UTF8' LC_COLLATE='ru_RU.UTF-8' LC_CTYPE='ru_RU.UTF-8' TEMPLATE=template0;
\c ctd;
create table Groups (
    group_id int,
    group_no char(6)
);
create table Students (
    student_id int,
    name varchar(30),
    group_id int
);
insert into Groups
    (group_id, group_no) values
    (1, 'M34371'),
    (2, 'M34391');
insert into Students
    (student_id, name, group_id) values
    (1, 'Erica Shefer', 2),
    (2, 'Daniil Boger', 1),
    (3, 'Ravil Galiev', 1);
    
select group_id, group_no from Groups;
select student_id, name, group_id from Students;

select name, group_no
    from Students natural join Groups;
select Students.name, Groups.group_no
    from Students
         inner join Groups
         on Students.group_id = Groups.group_id;
         
insert into Groups (group_id, group_no) values
    (1, 'M34381');
select group_id, group_no from Groups;
delete from Groups where group_no = 'M34381';
select group_id, group_no from Groups;
alter table Groups
    add constraint group_id_unique unique (group_id);
    
update Students set group_id = 5 where student_id = 1;
update Students set group_id = 1 where student_id = 1;
alter table Students add foreign key (group_id)
    references Groups (group_id);
