-record(org,      {id, name, subdomain, website, plan}).
-record(calendar, {id, orgid, name, opening, closing, timeblock, timezone}).
-record(account,  {id, orgid, fname, lname, phone, email, street, state, zipcode, password}).
-record(event,    {id, name, calendarid, accountid, stime, etime, ctime, status}).
-record(reminder, {id, accountid, recipient, body, kind}).

-define(config(Key),
    begin
        {ok, V} = application:get_env(dv, Key),
        V
    end).

-define(required_fields(Rec), [atom_to_binary(X, utf8)
    || X <- record_info(fields, Rec) -- [id]]).
