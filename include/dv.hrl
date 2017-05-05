-record(org,      {id, name, subdomain, website, plan, email, password, ctime}).
-record(contact,  {id, orgid, fname, lname, phone, email, ctime}).
-record(event,    {id, orgid, name, status, stime, etime, ctime}).
-record(reminder, {id, kind, target, body, status, runat}).
-record(event_reminder, {eventid, reminderid}).
-record(error,    {id, orgid, reminderid, kind, reason, ctime}).

-define(config(Key),
    begin
        {ok, V} = application:get_env(dv, Key),
        V
    end).

-define(required_fields(Rec), [atom_to_binary(X, utf8)
    || X <- record_info(fields, Rec) -- [id]]).
