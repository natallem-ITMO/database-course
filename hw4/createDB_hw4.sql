SET CLIENT_ENCODING TO 'utf8';

DROP database university;

CREATE database university WITH ENCODING 'UTF8' LC_COLLATE='ru_RU.UTF-8' LC_CTYPE='ru_RU.UTF-8' TEMPLATE=template0;

\c university;


CREATE TABLE "Groups" (
    "GroupId" int   NOT NULL,
    "GroupName" varchar(8)   NOT NULL,
    CONSTRAINT "pk_Groups" PRIMARY KEY (
        "GroupId"
    )
);

CREATE TABLE "Students" (
    "StudentId" int   NOT NULL,
    "StudentName" varchar(255)   NOT NULL,
    "GroupId" int   NOT NULL,
    CONSTRAINT "pk_Students" PRIMARY KEY (
        "StudentId"
    ),
    CONSTRAINT "fk_Students_GroupId"
        FOREIGN KEY("GroupId") 
        REFERENCES "Groups" ("GroupId")
);

CREATE TABLE "Courses" (
    "CourseId" int   NOT NULL,
    "CourseName" varchar(255)   NOT NULL,
    CONSTRAINT "pk_Courses" PRIMARY KEY (
        "CourseId"
    )
);

CREATE TABLE "Marks" (
    "CourseId" int   NOT NULL,
    "StudentId" int   NOT NULL,
    "Mark" int   NOT NULL,
    CONSTRAINT "pk_Marks" PRIMARY KEY (
        "CourseId",
        "StudentId"
    ),
    CONSTRAINT "fk_Marks_CourseId" 
        FOREIGN KEY("CourseId") 
        REFERENCES "Courses" ("CourseId"),
    CONSTRAINT "fk_Marks_StudentId" 
        FOREIGN KEY("StudentId") 
        REFERENCES "Students" ("StudentId")
);

CREATE TABLE "Lecturers" (
    "LecturerId" int NOT NULL,
    "LecturerName" varchar(255) NOT NULL,
    CONSTRAINT "pk_Lecturers" PRIMARY KEY (
        "LecturerId"
    )
);

CREATE TABLE "Plans" (
    "CourseId" int NOT NULL,
    "GroupId" int NOT NULL,
    "LecturerId" int NOT NULL,
    CONSTRAINT "pk_Plans" PRIMARY KEY (
        "CourseId",
        "GroupId"
    ),
    CONSTRAINT "fk_Plans_CourseId" 
        FOREIGN KEY("CourseId") 
        REFERENCES "Courses" ("CourseId"),
    CONSTRAINT "fk_Plans_GroupId" 
        FOREIGN KEY("GroupId") 
        REFERENCES "Groups" ("GroupId"),
    CONSTRAINT "fk_Plans_LecturerId" 
        FOREIGN KEY("LecturerId") 
        REFERENCES "Lecturers" ("LecturerId")
);


INSERT INTO "Groups"
    ("GroupId", "GroupName") VALUES
    (1, 'M34381'),
    (2, 'M34391'),
    (3, 'M34342');

INSERT INTO "Students"
    ("StudentId", "StudentName", "GroupId") VALUES
    (1, 'Агеев Роман Сергеевич', 1),
    (2, 'Акимов Николай Сергеевич', 1),
    (3, 'Акназаров Арслан Робертович', 2),
    (4, 'Бадикова Анастасия Вячеславовна', 3);

INSERT INTO "Courses"
    ("CourseId", "CourseName") VALUES
    (1,'Базы данных'),
    (2,'Теория кодирования'),
    (3,'Физическая культура'),
    (4,'Проектирование программного обеспечения');

INSERT INTO "Marks"
    ("CourseId", "StudentId", "Mark") VALUES
    (1, 1, 4),
    (2, 1, 4),
    (3, 1, 4),
    (4, 1, 4),
    (1, 2, 4),
    (1, 3, 5),
    (3, 4, 5);

INSERT INTO "Lecturers"  
    ("LecturerId", "LecturerName") VALUES
    (1, 'Георгий Александрович Корнеев'),
    (2, 'Трифонов Петр Владимирович'),
    (3, 'Мухамадеев Ренат Рустамович'),
    (4, 'Киракозов Александр Христофорович');

INSERT INTO "Plans"
    ("CourseId", "GroupId", "LecturerId") VALUES
    (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3),
    (4, 1, 4),
    (1, 2, 1),
    (3, 3, 3);
