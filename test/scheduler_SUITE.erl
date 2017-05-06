-module(scheduler_SUITE).

-export([all/0,
         minute_level/1]).

all() -> [minute_level].

minute_level(_) ->
    T1 = utils:drop_secs(utils:now()),

    Args = [Kind   = <<"sms">>,
            Target = utils:binhex(),
            Body   = utils:binhex(),
            RunAt  = T1],

    % when we insert new reminder, we always drop the seconds part
    % and when we query back, we query at minute level as well
    % assert: we can retrieve, and status is updated to 'processed' state
    {ok, 1} = db:squery(queries:new_reminder(), Args),

    Expected  = {ok, 1, a, [{b, Kind, Target, Body, <<"processed">>, RunAt}]},
    Result =
        db:squery(queries:fetch_and_schedule_reminders(), [T1]),


    ct:pal("expected:~p, actual:~p", [Expected, Result]).

