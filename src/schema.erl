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
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS orgs (
            id        SERIAL NOT NULL,
            name      TEXT NOT NULL,
            subdomain TEXT,
            website   TEXT,
            plan      TEXT NOT NULL)");

up(calendars) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS calendars (
            id        SERIAL NOT NULL,
            orgid     INTEGER NOT NULL,
            name      TEXT NOT NULL,
            opening   INTEGER NOT NULL,
            closing   INTEGER NOT NULL,
            timeblock INTEGER NOT NULL,
            timezone  TEXT NOT NULL)");

up(accounts) ->
    {ok, [], []} = db:squery(
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
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS events (
            id         SERIAL NOT NULL,
            name       TEXT NOT NULL,
            calendarid INTEGER NOT NULL,
            accountid  INTEGER NOT NULL,
            stime      TIMESTAMP NOT NULL,
            etime      TIMESTAMP NOT NULL,
            ctime      TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'utc'))");

up(reminders) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS reminders (
            id        SERIAL NOT NULL,
            accountid INTEGER NOT NULL,
            recipient TEXT NOT NULL,
            body      TEXT NOT NULL,
            kind      TEXT NOT NULL,
            status    TEXT NOT NULL,
            runat     TIMESTAMP NOT NULL)").

down() ->
    down(orgs),
    down(calendars),
    down(accounts),
    down(events),
    down(reminders).

down(orgs)      -> db:squery("DROP TABLE orgs");
down(calendars) -> db:squery("DROP TABLE calendars");
down(accounts)  -> db:squery("DROP TABLE accounts");
down(events)    -> db:squery("DROP TABLE events");
down(reminders) -> db:squery("DROP TABLE reminders").
