-- CREATE OR REPLACE FUNCTION increment(i integer) RETURNS integer AS $$
--         BEGIN
--                 RETURN i + 1;
--         END;
-- $$ LANGUAGE plpgsql;


--     DECLARE
--         ids INTEGER[];
--     BEGIN
--          ids := ARRAY[1,2];
--          RETURN QUERY
--              SELECT users.id, users.firstname, users.lastname
--              FROM public.users
--              WHERE users.id = ANY(ids);
--     END;

VALUES (1, current_timestamp + interval '1 day'),
-- select FreeSeats(1);

select CheckCredentials(1, 'hell');
select CheckCredentials(1, 'hell2');
select CheckCredentials(4, 'djfk');
select CheckCredentials(1, null);
select CheckCredentials(null, 'd');


-- -- drop table Tickets;
-- -- drop table Flights;
-- -- drop table Planes;
-- -- drop table Seats cascade ;
-- truncate table Seats cascade ;
--
-- insert into Planes(PlaneId) values (1);
-- insert into Seats (PlaneId, SeatNo) values
-- (1, '1A'),
-- (1, '1B'),
-- (1, '10A');
--
-- insert into Flights
--     (FlightId, FlightTime, PlaneId)
-- values (1, '2021-11-22 23:00:00', 1),
--        (2, '2022-09-13 20:00:00', 6);
--
--
-- SELECT LPAD(SeatNo::text, 4, '0')  -- Zero-pads to the left up to the length of 3
-- FROM Seats;
--
-- select SeatNo
--         from Seats
--         where PlaneId = 1
--         order by LPAD(SeatNo::text, 4, '0')
--                   asc
--             for update;
--
-- -- select (SeatNo) from Seats order by SeatNo ASC;
--
-- create or replace function CompressSeats(flight_id int)
-- returns table (
--             SeatId       int,
--             SeatName     varchar(4),
--             FullSeatName varchar(4)
--         )
-- as
-- $$
-- declare
--     seat_num int := 1;
--     seat_coursor cursor for
--         select SeatNo
--         from Seats
--         where PlaneId = (select PlaneId from Flights where FlightId = flight_d)
--         order by LPAD(SeatNo::text, 4, '0')
--             for update;
--     seat_name varchar(4);
-- --     FETCH cursor_name INTO variable_list;
-- begin
--     -- incorrect user
--     if not exists(select from Flights where FlightId = flight_id)
--     then
--         return ;
--     else
--         create table SeatNames
--         (
--             SeatId       int,
--             SeatName     varchar(4),
--             FullSeatName varchar(4)
--         );
--         for seat_name in select SeatNo
--                          from Seats
--                          where PlaneId = (select PlaneId from Flights where FlightId = flight_d)
--                          order by LPAD(SeatNo::text, 4, '0') asc
--             loop
--                 insert into SeatNames (SeatId, SeatName, FullSeatName)
--                 values (seat_num, seat_name, LPAD(seat_name::text, 4, '0'));
--
--             end loop;
--         return SeatNames;
--     end if;
-- end;
-- $$
--     called on null input
--     language plpgsql;
--
-- select CompressSeats(1);
