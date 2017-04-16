-module(schema).

-export([up/0, up/1,
         down/0, down/1,
         refresh/0]).

refresh() ->
    down(), up().

up() ->
    up(orgs),
    up(calendars),
    up(accounts),
    up(events),
    up(reminders).

up(orgs) ->
    {ok, [], []} = epgsql:squery(db:conn(),
        "CREATE TABLE IF NOT EXISTS orgs (
            id        SERIAL NOT NULL,
            name      TEXT NOT NULL,
            subdomain TEXT,
            website   TEXT,
            plan      TEXT NOT NULL)");

up(calendars) ->
    {ok, [], []} = epgsql:squery(db:conn(),
        "CREATE TABLE IF NOT EXISTS calendars (
            id        SERIAL NOT NULL,
            orgid     INTEGER NOT NULL,
            name      TEXT NOT NULL,
            opening   INTEGER NOT NULL,
            closing   INTEGER NOT NULL,
            timeblock INTEGER NOT NULL,
            timezone  TEXT NOT NULL)");

up(accounts) ->
    {ok, [], []} = epgsql:squery(db:conn(),
        "CREATE TABLE IF NOT EXISTS accounts (
            id        SERIAL NOT NULL,
            orgid     INTEGER,
            fname     TEXT,
            lname     TEXT,
            phone     TEXT,
            email     TEXT,
            street    TEXT,
            state     TEXT,
            zipcode   TEXT)"); % todo: password?, zipcode should be integer

up(events) ->
    {ok, [], []} = epgsql:squery(db:conn(),
        "CREATE TABLE IF NOT EXISTS events (
            id         SERIAL NOT NULL,
            name       TEXT,
            calendarid INTEGER,
            accountid  INTEGER,
            stime      TIMESTAMP NOT NULL,
            etime      TIMESTAMP NOT NULL,
            ctime      TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
            status     TEXT)");

up(reminders) ->
    {ok, [], []} = epgsql:squery(db:conn(),
        "CREATE TABLE IF NOT EXISTS reminders (
            id        SERIAL NOT NULL,
            accountid INTEGER,
            recipient TEXT,
            body      TEXT,
            kind      TEXT)").

down() ->
    down(orgs),
    down(calendars),
    down(accounts),
    down(events),
    down(reminders).

down(orgs)      -> epgsql:squery(db:conn(), "DROP TABLE orgs");
down(calendars) -> epgsql:squery(db:conn(), "DROP TABLE calendars");
down(accounts)  -> epgsql:squery(db:conn(), "DROP TABLE accounts");
down(events)    -> epgsql:squery(db:conn(), "DROP TABLE events");
down(reminders) -> epgsql:squery(db:conn(), "DROP TABLE reminders").
