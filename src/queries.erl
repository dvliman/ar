-module(queries).

-export([signup/0,
         org_exists/0,
         earliest_runat/0,
         new_reminder/0,
         fetch_and_schedule_reminders/0]).

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
        WHERE runat >= '~s'
        ORDER BY runat ASC
        LIMIT 1">>.

new_reminder() ->
    <<"INSERT INTO reminders (kind, target, body, status, runat)
        VALUES ('~s', '~s', '~s', 'new', '~s');">>.

fetch_and_schedule_reminders() ->
    <<"UPDATE reminders SET status = 'processed'
        FROM (SELECT id FROM reminders WHERE runat = '~s') AS subquery
        WHERE reminders.id = subquery.id
        RETURNING reminders.id as id, kind, target, body, status, iso8601(runat)">>.