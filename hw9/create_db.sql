SET CLIENT_ENCODING TO 'utf8';

-- DROP database if exists "Airline";
DROP database if exists "Airline";

CREATE database "Airline" WITH ENCODING 'UTF8' LC_COLLATE ='ru_RU.UTF-8' LC_CTYPE ='ru_RU.UTF-8' TEMPLATE =template0;

\c "Airline";

create type TicketType as enum ('booked', 'bought');

-- Храним Id самолетов, которые выходят
-- на рейсы
create table Planes
(
    PlaneId int not null,
    constraint "pk_Planes" primary key (PlaneId)
);
-- Информация о полетах, храним id полета как pk,
-- время отправления и id самолета вылета
create table Flights
(
    FlightId   int       not null,
    FlightTime timestamp not null,
    PlaneId    int       not null,
    constraint "pk_Flights" primary key (FlightId),
    constraint "pk_Flights_PlaneId" foreign key (PlaneId)
        references Planes (PlaneId)

);
-- Информация о местах в самолете
create table Seats
(
    PlaneId int        not null,
    SeatNo  varchar(4) not null,
    constraint "pk_Seats" primary key (PlaneId, SeatNo),
    constraint "pk_Seats_PlaneId" foreign key (PlaneId)
        references Planes (PlaneId)
);
-- Информация о пользователях, которые могут бронировать и
-- выкупать билеты. Необоходима регистрация.
create table Users
(
    UserId        int          not null,
    UserName      varchar(100) not null,
    EncryptedPass text         not null,
    constraint "pk_Users" primary key (UserId)
);
-- Информация о всех билетах (забронированых или
-- выкупленных). Сохраняем id полета и самолета
-- а так же само место. 2 типа билетов -
-- забронированные (тогда у них есть UserId,
-- ActionTime - время брони), выкупленные
-- (может не быть UserId (анонимная покупка),
-- ActionTime - время покупки
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
       (6);

insert into Flights
    (FlightId, FlightTime, PlaneId)
values (1, '2021-11-22 23:00:00', 5),
       (2, '2022-09-13 20:00:00', 5),
       (3, '2022-09-14 20:00:00', 6),
       (4, '2022-09-15 20:00:00', 6);

insert into Seats (PlaneId, SeatNo)
VALUES (5, 'A111'),
       (5, 'A222'),
       (5, 'A333'),
       (5, 'A444'),
       (6, 'B111'),
       (6, 'B222'),
       (6, 'B333'),
       (6, 'B444');

select *
from Flights;
create extension pgcrypto;

create or replace procedure RegisterUser(user_name varchar(100), pass text)
as
$$
begin
    insert into Users (UserId,
                       UserName,
                       EncryptedPass)
    values (coalesce((select max(UserId) from Users), 0) + 1,
            user_name,
            crypt(pass, gen_salt('md5')))
    on conflict do nothing;
end;
$$
    language plpgsql;

create or replace function CheckCredentials(user_id int, pass text) returns boolean
as
$$
DECLARE
    encrypted_pass TEXT := null;
begin
    if user_id is null or pass is null then
        return false;
    else
        encrypted_pass = (select EncryptedPass from Users where UserId = user_id);
        return encrypted_pass is not null and encrypted_pass = crypt(pass, encrypted_pass);
    end if;
end;
$$
    called on null input
    language plpgsql;


create view NotFreeTickets as
select *
from Tickets
where (Type = 'bought' or current_timestamp < ActionTime + interval '3 day');

create or replace function FreeSeats(flight_id int)
    returns table
            (
                SeatNo varchar(4)
            )
as
$$
begin
    if current_timestamp + interval '2 hours' > (
        select FlightTime
        from Flights
        where FlightId = flight_id)
    then
        return;
    else
        return query
            select s.SeatNo as SeatNo
            from Flights f
                     natural join Seats s
            where f.FlightId = flight_id
            except
            select nft.SeatNo as SeatNo
            from NotFreeTickets nft
            where nft.FlightId = flight_id;
    end if;
end;
$$
    language plpgsql
    returns null on null input;

call RegisterUser('Natasha L', 'hell');
call RegisterUser('Natasha M', 'df');

create or replace function Reserve(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- flight is too soon
    if (current_timestamp + interval '2 hours' > (
        select FlightTime
        from Flights
        where FlightId = flight_id))
        or
        -- user is incorrect
       (not CheckCredentials(user_id, pass))
        or
        -- no such seat in the plane
       (not exists(
               select 1
               from Flights
                        natural join Seats
               where FlightId = flight_id
                 and SeatNo = seat_no))
        or
        -- ticket has already booked or bought
       ((select 1
         from Tickets
         where FlightId = flight_id
           and SeatNo = seat_no
           and (Type = 'bought'
             or current_timestamp < ActionTime + interval '3 day')) is not null)
    then
        return false;
    else
        delete from Tickets where FlightId = flight_id and SeatNo = seat_no;
        insert into Tickets (FlightId, PlaneId, SeatNo, UserId, Type, ActionTime)
        values (flight_id,
                (select PlaneId from Flights where FlightId = flight_id),
                seat_no,
                user_id,
                'booked',
                current_timestamp);
        return true;
    end if;
end;
$$
    language plpgsql
    returns null on null input;

select FreeSeats(1);
select Reserve(1, 'hell', 1, 'A111'); -- t
select Reserve(1, 'hwll', 1, 'A333'); -- f
select Reserve(1, 'hell', 1, 'A111'); -- f
select Reserve(1, 'hell', 1, 'A222'); -- t
select Reserve(1, 'hell', 1, 'A228'); -- f
select FreeSeats(1);


create or replace function ExtendReservation(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- flight is too soon
    if (current_timestamp + interval '2 hours' > (
        select FlightTime
        from Flights
        where FlightId = flight_id))
        or
        -- user is incorrect
       (not CheckCredentials(user_id, pass))
        or
        -- no such seat in the plane
       (not exists(
               select 1
               from Flights
                        natural join Seats
               where FlightId = flight_id
                 and SeatNo = seat_no))
        or
        -- there is no booked ticked by this user
       (not exists(select 1
                   from Tickets
                   where FlightId = flight_id
                     and SeatNo = seat_no
                     and UserId = user_id
                     and Type = 'booked'
                     and current_timestamp < ActionTime + interval '3 day'))
    then
        return false;
    else
        -- because of previous if condition we know that
        -- tickets is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    language plpgsql
    returns null on null input;

select ExtendReservation(1, 'her', 1, 'A111'); -- f
select ExtendReservation(1, 'hell', 1, 'A111'); -- t
select ExtendReservation(1, 'hell', 1, 'A1e1'); -- f
select ExtendReservation(2, 'hell', 1, 'A222'); -- f
select ExtendReservation(2, 'hell', 1, 'A333'); -- f

create or replace function BuyFree(
    flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- flight is too soon
    if (current_timestamp + interval '2 hours' > (
        select FlightTime
        from Flights
        where FlightId = flight_id))
        or
        -- no such seat in the plane
       (not exists(
               select 1
               from Flights
                        natural join Seats
               where FlightId = flight_id
                 and SeatNo = seat_no))
        or
        -- ticket has already booked or bought
       ((select 1
         from Tickets
         where FlightId = flight_id
           and SeatNo = seat_no
           and (Type = 'bought'
             or current_timestamp < ActionTime + interval '3 day')) is not null)
    then
        return false;
    else
        delete from Tickets where FlightId = flight_id and SeatNo = seat_no;
        insert into Tickets (FlightId, PlaneId, SeatNo, UserId, Type, ActionTime)
        values (flight_id,
                (select PlaneId from Flights where FlightId = flight_id),
                seat_no,
                null,
                'bought',
                current_timestamp);
        return true;
    end if;
end;
$$
    language plpgsql
    returns null on null input;


select BuyFree(2, 'df'); -- f
select BuyFree(43, 'df'); -- f
select BuyFree(1, 'A111'); -- f
select BuyFree(1, 'A333'); -- t
select BuyFree(1, 'A333'); -- f
select FreeSeats(1);
select BuyFree(1, 'A444'); -- t
select FreeSeats(1);

create or replace function BuyReserved(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- no such flight
--     if (not exists(select FlightTime
--         from Flights
--         where FlightId = flight_id))
--         or
        -- flight is too soon
    if    (current_timestamp + interval '2 hours' > (
        select FlightTime
        from Flights
        where FlightId = flight_id))
        or
        -- user is incorrect
       (not CheckCredentials(user_id, pass))
        or
        -- no such seat in the plane
       (not exists(
               select 1
               from Flights
                        natural join Seats
               where FlightId = flight_id
                 and SeatNo = seat_no))
        or
        -- there is no booked ticked by this user
       (not exists(select 1
                   from Tickets
                   where FlightId = flight_id
                     and SeatNo = seat_no
                     and UserId = user_id
                     and Type = 'booked'
                     and current_timestamp < ActionTime + interval '3 day'))
    then
        return false;
    else
        -- because of previous if condition we know that
        -- tickets is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    language plpgsql
    returns null on null input;

-- select BuyFree(2, 'df'); -- f

