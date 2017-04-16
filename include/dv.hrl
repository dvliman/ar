-define(config(Key),
    begin
        {ok, V} = application:get_env(dv, Key),
        V
    end).

-record(org,         {id, name, subdomain, website, plan}).
-record(calendar,    {id, name, opening, closing, timeblock, timezone}).
-record(account,     {id, fname, lname, phone, email, street, state, zipcode, password}).
-record(event,       {id, name, calendarid, accountid, stime, etime, ctime, status}).
-record(reminder,    {id, accountid, recipient, body, kind}).
