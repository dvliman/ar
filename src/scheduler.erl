-module(scheduler).
-behavior(gen_server).

-record(state, {tref, ts}).

-export([init/1,
         start_link/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(ONE_MINUTE, 60000). % in milliseconds

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

init([]) ->
    {ok, next_state(#state{})}.

handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(wakeup, #state{ts = Timestamp} = State) ->
    case db:squery(queries:fetch_and_schedule_reminders(), [Timestamp]) of
        {ok, 0} ->
            no_work_sleep_again;
        {ok, _, _, Reminders} ->
            lists:foreach(fun dispatch/1, Reminders)
    end,

    {noreply, next_state(State)}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

dispatch({Id, OrgId, <<"sms">>, To, Body, _, _}) ->
    erlang:spawn(twilio, accept, [Id, OrgId, To, Body]);
dispatch({Id, OrgId, <<"email">>, To, Body, _, _}) ->
    erlang:spawn(sendgrid, accept, [Id, OrgId, To, Body]).

next_state(#state{tref = undefined}) ->
    new_state(utils:now());
next_state(#state{tref = Tref, ts = LastTimestamp}) when is_reference(Tref) ->
    timer:cancel(Tref),
    new_state(LastTimestamp).

new_state(Since) ->
    {SleepTime, Next} = get_sleep_time(Since),

    #state{ts = Next,
           tref = erlang:send_after(SleepTime, ?MODULE, wakeup)}.

% return {sleep-time :: milliseconds(), next :: iso8601()}
% we return the 'next' value so that if the scheduler
% is slowing down, we dont skip, we recover from last processed
get_sleep_time(Since) ->
    case db:squery(queries:earliest_runat(), [Since]) of
        {ok, _, []} ->
            % there is no next earliest reminder, check again in a minute
            {MegaSecs, Secs, MicroSecs} = erlang:timestamp(),
            Next = {MegaSecs, Secs + 60, MicroSecs},
            {?ONE_MINUTE, iso8601:format(Next)};

        {ok, _, [{Next}]} ->
            Diff = utils:utc_diff(Next, utils:now()),
            {Diff, Next}
    end.

