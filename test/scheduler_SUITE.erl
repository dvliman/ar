-module(scheduler_SUITE).

-export([all/0,
         minute_level/1,
         earliest_runat/1]).

all() -> [minute_level,
          earliest_runat].

minute_level(_) ->
    Args = [99, % orgid
            Kind   = <<"sms">>,
            Target = utils:binhex(),
            Body   = utils:binhex(),
            RunAt  = utils:now()],

    % assert: insert and query on the same timestamp
    % would return the same row (note: we truncate seconds when query at minute level)
    {ok, 1} = db:squery(queries:new_reminder(), Args),

    {ok, _, _, MaybeRows} =
        db:squery(queries:fetch_and_schedule_reminders(), [RunAt]),

    % if you run this test several times within a minute
    % you are going to match for multiple, assert just 1 matching
    true = lists:any(
        fun({_, _, K, T, B, _, R}) when
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
    T1 = utils:increment_minute(T0, 10),
    T2 = utils:increment_minute(T0, 5), % inserted later but is actually earlier

    Args1 = [99, <<"sms">>, utils:binhex(), utils:binhex(), T1],
    Args2 = [99, <<"sms">>, utils:binhex(), utils:binhex(), T2],

    ct:pal("t1:~p, t2:~p, args1:~p", [T1, T2, Args1]),
    {ok, 1} = db:squery(queries:new_reminder(), Args1),
    {ok, 1} = db:squery(queries:new_reminder(), Args2),

    {ok, _, [{T2}]} = db:squery(queries:earliest_runat(), [T0]).

truncate_reminders_table() ->
    {ok, [], []} = db:squery("TRUNCATE reminders").
