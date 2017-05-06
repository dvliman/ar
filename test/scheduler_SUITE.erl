-module(scheduler_SUITE).

-export([all/0,
         minute_level/1,
         earliest_runat/1,
         earliest_runat_equals_now/1]).

all() -> [minute_level,
          earliest_runat,
          earliest_runat_equals_now].

minute_level(_) ->
    Args = [Kind   = <<"sms">>,
            Target = utils:binhex(),
            Body   = utils:binhex(),
            RunAt  = utils:now()],

    % assert: insert and query on the same timestamp
    % would return the same row (note: we truncate seconds level when we query)
    {ok, 1} = db:squery(queries:new_reminder(), Args),

    {ok, _, _, MaybeRows} =
        db:squery(queries:fetch_and_schedule_reminders(), [RunAt]),

    % if we run this test several times within a minute
    % you are going to match for multiple
    true = lists:any(
        fun({_, K, T, B, _, R}) when
            K =:= Kind,
            T =:= Target,
            B =:= Body,
            R =:= RunAt ->
                true;
           (_) ->
               false
        end, MaybeRows).

earliest_runat(_) ->
    truncate_reminders_table(),

    T0 = utils:now(),
    T1 = increment_minute(T0, 10),
    T2 = increment_minute(T0, 5), % inserted later but is actually earlier

    Args1 = [<<"sms">>, utils:binhex(), utils:binhex(), T1],
    Args2 = [<<"sms">>, utils:binhex(), utils:binhex(), T2],

    {ok, 1} = db:squery(queries:new_reminder(), Args1),
    {ok, 1} = db:squery(queries:new_reminder(), Args2),

    {ok, _, [{T2}]} = db:squery(queries:earliest_runat(), [T0]).

earliest_runat_equals_now(_) ->
    Now = utils:now(),
    Args1 = [<<"sms">>, utils:binhex(), utils:binhex(), Now],
    Args2 = [<<"sms">>, utils:binhex(), utils:binhex(), Now],
    {ok, 1} = db:squery(queries:new_reminder(), Args1),
    {ok, 1} = db:squery(queries:new_reminder(), Args2),

    % assert: match now and only 1 result
    {ok, _, [{Now}]} = db:squery(queries:earliest_runat(), [Now]).

truncate_reminders_table() ->
    {ok, [], []} = db:squery("TRUNCATE reminders").

increment_minute(Utc, HowMany) when HowMany > 0; HowMany < 60->
    {Date, {Hour, Minute, Seconds}} = iso8601:parse(Utc),
    iso8601:format({Date, {Hour, Minute + HowMany, Seconds}}).