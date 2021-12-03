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
