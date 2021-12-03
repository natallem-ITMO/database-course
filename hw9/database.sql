SET CLIENT_ENCODING TO 'utf8';

-- DROP database if exists "Airline";
DROP database if exists "Airline";

CREATE database "Airline" WITH ENCODING 'UTF8' LC_COLLATE ='ru_RU.UTF-8' LC_CTYPE ='ru_RU.UTF-8' TEMPLATE =template0;

\c "Airline";

create type TicketType as enum ('booked', 'bought');

create table Planes
(
    PlaneId int not null,
    constraint "pk_Planes" primary key (PlaneId)
);
create table Flights
(
    FlightId   int       not null,
    FlightTime timestamp not null,
    PlaneId    int       not null,
    constraint "pk_Flights" primary key (FlightId),
    constraint "pk_Flights_PlaneId" foreign key (PlaneId)
        references Planes (PlaneId)

);
create table Seats
(
    PlaneId int        not null,
    SeatNo  varchar(4) not null,
    constraint "pk_Seats" primary key (PlaneId, SeatNo),
    constraint "pk_Seats_PlaneId" foreign key (PlaneId)
        references Planes (PlaneId)
);
create table Users
(
    UserId        int          not null,
    UserName      varchar(100) not null,
    EncryptedPass text         not null,
    constraint "pk_Users" primary key (UserId)
);
create table Tickets
(
    FlightId   int        not null,
    PlaneId    int        not null,
    SeatNo     varchar(4) not null,
    UserId     int,
    Type       TicketType not null,
    ActionTime timestamp  not null,
    constraint "pk_Tickets" primary key (FlightId, SeatNo),
    constraint "fk_Tickets_FlightId" foreign key (FlightId)
        references Flights (FlightId),
    constraint "fk_Tickets_SeatNo" foreign key (PlaneId, SeatNo)
        references Seats (PlaneId, SeatNo),
    constraint "fk_Tickets_UserId" foreign key (UserId)
        references Users (UserId),
    constraint "pk_Tickets_PlaneId" foreign key (PlaneId)
        references Planes (PlaneId)
);

insert into Planes (PlaneId)
values (5),
       (6),
       (7);

insert into Flights
    (FlightId, FlightTime, PlaneId)
values (1, '2021-11-22 23:00:00', 5),
       (2, '2022-09-13 20:00:00', 6),
       (3, '2022-09-13 20:00:00', 7)
--        (3, '2022-09-14 20:00:00', 6),
--        (4, '2022-09-15 20:00:00', 6)
;

insert into Seats (PlaneId, SeatNo)
VALUES (5, 'A1'),
       (5, 'A10'),
       (5, 'A333'),
       (5, 'A444'),
       (6, 'B111'),
       (6, 'B222'),
       (6, 'B333'),
       (6, 'B444'),
       (7, '1A'),
       (7, '1B'),
       (7, '10A'),
       (7, '100A'),
       (7, '1C'),
       (7, '100C');


