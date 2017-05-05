-module(schema).

-export([up/0, up/1,
         down/0, down/1,
         refresh/0]).

refresh() ->
    down(), up().

up() ->
    up(iso8601),
    up(orgs),
    up(contacts),
    up(events),
    up(reminders),
    up(event_reminders),
    up(errors).

up(iso8601) ->
    db:squery(
        "CREATE FUNCTION iso8601(ts timestamp) RETURNS CHARACTER AS $$
            SELECT TO_CHAR(ts::timestamp AT TIME ZONE \'UTC\', \'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"\')
            $$ LANGUAGE SQL IMMUTABLE;");

up(orgs) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS orgs (
            id        SERIAL NOT NULL,
            name      TEXT NOT NULL,
            subdomain TEXT NOT NULL,
            website   TEXT NOT NULL,
            plan      TEXT NOT NULL,
            email     TEXT NOT NULL,
            password  TEXT NOT NULL,
            ctime     TIMESTAMP NOT NULL)");

up(contacts) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS contacts (
            id        SERIAL NOT NULL,
            orgid     INTEGER NOT NULL,
            fname     TEXT NOT NULL,
            lname     TEXT NOT NULL,
            phone     TEXT NOT NULL,
            email     TEXT NOT NULL,
            ctime     TIMESTAMP NOT NULL)");

up(events) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS events (
            id     SERIAL NOT NULL,
            orgid  INTEGER NOT NULL,
            name   TEXT NOT NULL,
            status TEXT NOT NULL,
            stime  TIMESTAMP NOT NULL,
            etime  TIMESTAMP NOT NULL,
            ctime  TIMESTAMP NOT NULL)");

up(reminders) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS reminders (
            id        SERIAL NOT NULL,
            kind      TEXT NOT NULL,
            target    TEXT NOT NULL,
            body      TEXT NOT NULL,
            status    TEXT NOT NULL,
            runat     TIMESTAMP NOT NULL)");

up(event_reminders) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS event_reminders (
            eventid    INTEGER NOT NULL,
            reminderid INTEGER NOT NULL);");

up(errors) ->
    {ok, [], []} = db:squery(
        "CREATE TABLE IF NOT EXISTS errors (
            id         SERIAL NOT NULL,
            orgid      INTEGER NOT NULL,
            reminderid INTEGER NOT NULL,
            kind       TEXT NOT NULL,
            reason     TEXT NOT NULL,
            ctime      TIMESTAMP NOT NULL);").

down() ->
    down(iso8601),
    down(orgs),
    down(contacts),
    down(events),
    down(reminders),
    down(event_reminders),
    down(errors).

down(iso8601)   -> db:squery("DROP FUNCTION iso8601(timestamp)");
down(orgs)      -> db:squery("DROP TABLE orgs");
down(contacts)  -> db:squery("DROP TABLE contacts");
down(events)    -> db:squery("DROP TABLE events");
down(reminders) -> db:squery("DROP TABLE reminders");
down(event_reminders) -> db:squery("DROP TABLE event_reminders");
down(errors) -> db:squery("DROP TABLE errors").
