-module(queries).

-export([signup/0,
         org_exists/0,
         earliest_runat/0,
         new_reminder/0,
         mark_as_sent/0,
         fetch_and_schedule_reminders/0,
         report_error/0]).

signup() ->
    <<"BEGIN;
        INSERT INTO orgs (name, subdomain, website, plan, email, password, ctime)
            VALUES ('~s', '~s', '~s', 'free', '~s', '~s', '~s');
        SELECT id, name, subdomain, website, plan, email, iso8601(ctime)
            FROM orgs WHERE id = currval('orgs_id_seq');
      COMMIT;">>.

org_exists() ->
    <<"SELECT EXISTS (SELECT id FROM orgs WHERE id = ~b)">>.

earliest_runat() ->
    <<"SELECT iso8601(runat)
        FROM reminders
        WHERE date_trunc('minute', runat) > date_trunc('minute', '~s'::timestamp)
        ORDER BY runat ASC
        LIMIT 1">>.

new_reminder() ->
    <<"INSERT INTO reminders (orgid, kind, target, body, status, runat)
        VALUES ('~b','~s', '~s', '~s', 'new', '~s');">>.

mark_as_sent() ->
    <<"UPDATE reminders SET status = 'sent' WHERE id = '~s'">>.

fetch_and_schedule_reminders() ->
    <<"UPDATE reminders SET status = 'scheduled'
        FROM (
            SELECT id
            FROM reminders
            WHERE date_trunc('minute', runat) = date_trunc('minute', '~s'::timestamp)) AS subquery
        WHERE reminders.id = subquery.id
        RETURNING reminders.id as id, orgid, kind, target, body, status, iso8601(runat)">>.

report_error() ->
    <<"BEGIN;
        UPDATE reminders SET status = 'error' WHERE id = '~s';
        INSERT INTO errors (orgid, reminderid, kind, reason, ctime)
            VALUES ('~b', '~b', '~s', '~s', '~s');
       COMMIT;">>.

