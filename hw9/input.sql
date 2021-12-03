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


create extension pgcrypto;

-- Процедура регистрации пользователя для последующей проверки
-- введенного пароля, которые сохраняем здесь.
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

-- Проверка, что пользователь с таким именем есть в системе
-- и что его пароль верен
create or replace function CheckCredentials(user_id int, pass text)
    returns boolean
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

-- Проверяем, что данный рейс существует, что на самолете для данного рейса
-- есть такое место, что рейс еще не вылетел
create or replace function CheckFlightInfo(flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    if flight_id is null or seat_no is null
    then
        return false;
    else
        return exists(select 1
                      from Flights
                               natural join Seats
                      where Flights.FlightId = flight_id
                        and current_timestamp < FlightTime
                        and SeatNo = seat_no);
    end if;
end;
$$
    called on null input
    language plpgsql;

-- Представление билетов, которые заняты (забронированы или проданы)
create view NotFreeTickets(FlightId, PlaneId, SeatNo, UserId, Type, ActionTime) as
select *
from Tickets
where (Type = 'bought' or current_timestamp < ActionTime + interval '3 day');

call RegisterUser('Natasha L', 'hell');
call RegisterUser('Natasha M', 'hell2');
create or replace function FreeSeats(flight_id int)
    returns table
            (
                SeatNo varchar(4)
            )
as
$$
begin
    return query
        select s.SeatNo as SeatNo
        from Flights f
                 natural join Seats s
        where f.FlightId = flight_id
          and current_timestamp < f.FlightTime
        except
        select nft.SeatNo as SeatNo
        from NotFreeTickets nft
        where nft.FlightId = flight_id;
end;
$$
    called on null input
    language plpgsql;

select FreeSeats(1); -- full
select FreeSeats(134); -- empty
select FreeSeats(null); -- empty


create or replace function Reserve(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
        or
        -- incorrect flight or seat
       (not CheckFlightInfo(flight_id, seat_no))
       or
        -- ticket has already booked or bought
        (exists (select 1 from NotFreeTickets where FlightId = flight_id and SeatNo = seat_no))
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
    called on null input
    language plpgsql;

-- select FreeSeats(1);
-- select Reserve(1, 'hell', 1, 'A228'); -- f
-- select Reserve(null, 'hell', 1, 'A111'); -- f
-- select Reserve(1, null, 1, 'A111'); -- f
-- select Reserve(1, 'hell', null, 'A111'); -- f
-- select Reserve(1, 'hell', 1, null); -- f
-- select Reserve(1, 'hel', 1, 'A111'); -- f
-- select Reserve(1, 'hell', 1, 'A111'); -- t
-- select Reserve(1, 'hell', 1, 'A111'); -- f
-- select Reserve(2, 'hell2', 1, 'A222'); -- t
-- select FreeSeats(1);
create or replace function ExtendReservation(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
        or
        -- incorrect flight or seat
       (not CheckFlightInfo(flight_id, seat_no))
        or
        -- ticket hasn't booked by this user
       (not exists(select 1
                   from NotFreeTickets
                   where FlightId = flight_id
                     and SeatNo = seat_no
                     and Type = 'booked'
                     and UserId = user_id))
    then
        return false;
    else
        -- because of previous 'if condition' we know that
        -- ticket is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;

select FreeSeats(1);
-- select ExtendReservation(1, 'hell', 1, 'A228'); -- f
-- select ExtendReservation(null, 'hell', 1, 'A111'); -- f
-- select ExtendReservation(1, null, 1, 'A111'); -- f
-- select ExtendReservation(1, 'hell', null, 'A111'); -- f
-- select ExtendReservation(1, 'hell', 1, null); -- f
-- select ExtendReservation(1, 'hel', 1, 'A111'); -- f
-- select ExtendReservation(1, 'hell', 1, 'A111'); -- t
-- select ExtendReservation(1, 'hell', 1, 'A111'); -- t
-- select ExtendReservation(1, 'hell', 1, 'A222'); -- f
-- select ExtendReservation(2, 'hell2', 1, 'A222'); -- t
--

create or replace function BuyFree(
    flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect flight or seat
    if (not CheckFlightInfo(flight_id, seat_no))
        or
        -- ticket has already booked or bought
       (exists(select 1
               from NotFreeTickets
               where FlightId = flight_id
                 and SeatNo = seat_no))
    then
        return false;
    else
        insert into Tickets (FlightId,
                             PlaneId,
                             SeatNo,
                             UserId,
                             Type,
                             ActionTime)
        values (flight_id,
                (select PlaneId from Flights where FlightId = flight_id),
                seat_no,
                null,
                'bought',
                current_timestamp)
        on conflict (FlightId, SeatNo)
            do update set UserId     = null,
                          Type       = 'bought',
                          ActionTime = current_timestamp;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;

-- select BuyFree(1, 'A123'); -- f
-- select BuyFree(43, 'A123'); -- f
-- select BuyFree(1, 'A111'); -- f
-- select BuyFree(null, 'A333'); -- f
-- select BuyFree(1, null); -- f
-- select BuyFree(1, 'A333'); -- t
-- select BuyFree(1, 'A333'); -- f
-- select FreeSeats(1);

create or replace function BuyReserved(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
        or
        -- incorrect flight or seat
       (not CheckFlightInfo(flight_id, seat_no))
        or
        -- ticket hasn't booked by this user
       (not exists(select 1
                   from NotFreeTickets
                   where FlightId = flight_id
                     and SeatNo = seat_no
                     and Type = 'booked'
                     and UserId = user_id))
    then
        return false;
    else
        -- because of previous if condition we know that
        -- tickets is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp,
            Type = 'bought'
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;


-- select BuyReserved(null, 'hell', 1, 'A111'); -- f
-- select BuyReserved(1, null, 1, 'A111'); -- f
-- select BuyReserved(1, 'hell', null, 'A111'); -- f
-- select BuyReserved(1, 'hell', 1, null); -- f
-- select BuyReserved(1, 'hel', 1, 'A111'); -- f
-- select BuyReserved(1, 'hell', 1, 'A111'); -- t
-- select BuyReserved(1, 'hell', 1, 'A222'); -- f
-- select BuyReserved(2, 'hell2', 1, 'A222'); -- t
-- select BuyReserved(2, 'hell2', 1, 'A444'); -- f
create or replace procedure CompressSeats(flight_id int)
as
$$
declare
    seat_num  int := 1;
    seat_name varchar(4);
    booked_cursor cursor for
        select *
        from NotFreeTickets
        where FlightId = flight_id
          and Type = 'booked'
        order by LPAD(SeatNo::text, 4, '0')
            for update;
    bought_cursor cursor for
        select *
        from Tickets
                 natural join Flights
        where FlightId = flight_id
          and FlightTime > current_timestamp
          and Type = 'bought'
        order by LPAD(SeatNo::text, 4, '0')
            for update;
begin
    -- incorrect flight
    if not exists(select from Flights where FlightId = flight_id)
    then
        return ;
    else
        create temporary table SeatNames
        (
            SeatId   int,
            SeatName varchar(4)
        );
        create temporary table SeatRenaming
        (
            PrevName varchar(4),
            SeatId   int,
            constraint seat_renaming_pk primary key (PrevName)
        );
        for seat_name in select SeatNo
                         from Seats
                         where PlaneId =
                               (select PlaneId from Flights where FlightId = flight_id)
                         order by LPAD(SeatNo::text, 4, '0')
            loop
                insert into SeatNames (SeatId, SeatName)
                values (seat_num, seat_name);
                seat_num := seat_num + 1;
            end loop;
        seat_num := 1;
        for _ in bought_cursor
            loop
                fetch bought_cursor into seat_name;
                update Tickets
                set SeatNo = (select SeatName from SeatNames where SeatId = seat_num)
                where current of bought_cursor;
                seat_num := seat_num + 1;
            end loop;
        for _ in booked_cursor
            loop
                fetch booked_cursor into seat_name;
                update Tickets
                set SeatNo = (select SeatName from SeatNames where SeatId = seat_num)
                where current of booked_cursor;
                seat_num := seat_num + 1;
            end loop;
    end if;
end;
$$
    language plpgsql;

select Reserve(1, 'hell', 3, '1B');
select Reserve(2, 'hell2', 3, '10A');
select Reserve(2, 'hell2', 3, '100A');
select BuyReserved(2, 'hell2', 3, '100A');
-- select BuyReserved(1,)
select *
from Tickets;

select SeatNo
from Seats
where PlaneId =
      (select PlaneId from Flights where FlightId = 3)
order by LPAD(SeatNo::text, 4, '0');


call CompressSeats(3);

select *
from Tickets;
