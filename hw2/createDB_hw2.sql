SET CLIENT_ENCODING TO 'utf8';

DROP database university;

CREATE database university WITH ENCODING 'UTF8' LC_COLLATE='ru_RU.UTF-8' LC_CTYPE='ru_RU.UTF-8' TEMPLATE=template0;

\c university;

CREATE TABLE "Students" (
    "Id" int   NOT NULL  generated always AS identity,
    "FirstName" varchar(30)   NOT NULL,
    "SecondName" varchar(30)   NOT NULL,
    "Course" int   NOT NULL,
    "GroupId" int   NOT NULL,
    CONSTRAINT "pk_Students" PRIMARY KEY (
        "Id"
     ),
    CONSTRAINT valid_course CHECK ("Course" >= 1 AND "Course" <= 7)
);

CREATE TABLE "Groups" (
    "Id" int   NOT NULL   generated always AS identity,
    "GroupName" varchar(30)   NOT NULL,
    CONSTRAINT "pk_Groups" PRIMARY KEY (
        "Id"
     )
);

CREATE TABLE "StudentSubject" (
    "StudentId" int   NOT NULL,
    "SubjectId" int   NOT NULL,
    CONSTRAINT "pk_StudentSubject" PRIMARY KEY (
        "StudentId","SubjectId"
     )
);

CREATE TABLE "Subjects" (
    "Id" int   NOT NULL   generated always AS identity,
    "SubjectName" varchar(255)   NOT NULL,
    "ProfessorId" int   NOT NULL,
    CONSTRAINT "pk_Subjects" PRIMARY KEY (
        "Id"
     )
);

CREATE TABLE "Professors" (
    "Id" int   NOT NULL   generated always AS identity,
    "FirstName" varchar(30)   NOT NULL,
    "SecondName" varchar(30)   NOT NULL,
    "Patronymic" varchar(30)   NULL,
    "Experience" int   NOT NULL,
    "SubjectId" int   NOT NULL,
    CONSTRAINT "pk_Professors" PRIMARY KEY (
        "Id"
     ),
    CONSTRAINT "valid_experience" CHECK("Experience" >= 0)
);

CREATE TABLE "Grade" (
    "StudentId" int   NOT NULL,
    "SubjectId" int   NOT NULL,
    "MarkId" int   NULL,
    "AssessmentDate" date   NULL,
    "ClosingDate" date   NOT NULL,
    CONSTRAINT "pk_Grade" PRIMARY KEY (
        "StudentId","SubjectId"
     )
);

CREATE TABLE "Marks" (
    "Mark" int   NOT NULL,
    CONSTRAINT "pk_Marks" PRIMARY KEY (
        "Mark"
     ),
    CONSTRAINT valid_mark CHECK ("Mark" >= 1 AND "Mark" <= 5)
);

ALTER TABLE "Students" ADD CONSTRAINT "fk_Students_GroupId" FOREIGN KEY("GroupId")
REFERENCES "Groups" ("Id");

ALTER TABLE "StudentSubject" ADD CONSTRAINT "fk_StudentSubject_StudentId" FOREIGN KEY("StudentId")
REFERENCES "Students" ("Id");

ALTER TABLE "StudentSubject" ADD CONSTRAINT "fk_StudentSubject_SubjectId" FOREIGN KEY("SubjectId")
REFERENCES "Subjects" ("Id");

ALTER TABLE "Subjects" ADD CONSTRAINT "fk_Subjects_SubjectId" FOREIGN KEY("SubjectId")
REFERENCES "Professors" ("Id");

ALTER TABLE "Professors" ADD CONSTRAINT "fk_Professors_SubjectId" FOREIGN KEY("SubjectId")
REFERENCES "Subjects" ("Id") DEFERRABLE INITIALLY DEFERRED;


ALTER TABLE "Grade" ADD CONSTRAINT "fk_Grade_StudentId_SubjectId" FOREIGN KEY("StudentId", "SubjectId")
REFERENCES "StudentSubject" ("StudentId", "SubjectId");


INSERT INTO "Groups"
    ("GroupName") VALUES
    ('M34371'),
    ('M3438'),
    ('M34391');
    
SELECT "Id", "GroupName" FROM "Groups";

INSERT INTO "Students"
    ("FirstName", "SecondName", "Course", "GroupId") VALUES
    ('Наталья', 'Лемешкова', 4, 1),
    ('Рашо', 'Елизавета', 4, 1),
    ('Глеб', 'Ковешников', 2, 1),
    ('Илона', 'Боже', 3, 3);
    

BEGIN;

INSERT INTO "Professors"
    ("FirstName", "SecondName", "Patronymic", "Experience", "SubjectId") VALUES
    ('Александр', 'Станкевич', 'Станкевич', 25, 1),
    ('Павел', 'Маврин', null, 4, 2),
    ('Ольга', 'Семенова', 'Львовна', 20, 3);

INSERT INTO "Subjects"
    ("SubjectName", "ProfessorId") VALUES
    ('Дискретная математика', 1),
    ('Алгоритмы и структуры данных', 2),
    ('Методы трансляции', 1),
    ('Математический анализ', 3);
    
COMMIT;

SELECT "Professors"."SecondName", "Subjects"."SubjectName"
    FROM "Professors"
         INNER JOIN "Subjects"
         ON "Subjects"."ProfessorId" = "Professors"."SubjectId";
         
INSERT INTO "StudentSubject"
    ("StudentId", "SubjectId") VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 3),
    (3, 2),
    (4, 1);


INSERT INTO "Marks"
    ("Mark") VALUES
    (1), (2), (3), (4), (5);

           
INSERT INTO "Grade"
    ("StudentId", "SubjectId", "MarkId", "AssessmentDate", "ClosingDate") VALUES
    (1, 1, 5, '2001-01-18', '2019-01-18'),
    (2, 3, 3, '2001-01-18', '2019-01-18'),
    (3, 2, 4, '2001-09-28', '2019-01-18'),
    (4, 1, null, null, '2022-01-18'),
    (1, 2, 5, '2001-09-28', '2019-01-18'),
    (1, 3, 5, '2001-01-18', '2019-01-18');

