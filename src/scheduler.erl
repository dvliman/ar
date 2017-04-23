-module(scheduler).
-behavior(gen_server).

-record(state, {tref, next}).

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
    {SleepUntil, Next} = get_sleep_time(),
    Tref = erlang:send_after(SleepUntil, scheduler, {wakeup, Next}),

    {ok, #state{tref = Tref,
                next = Next}}.

handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({wakeup, Time}, State) ->
    % get all reminders to be send (drop the minute part)
    % cast it to twitter or sendgrid
    % check all possible failure message (and report per org, and to admin)
    % recompute sleep time and when to wakeup next
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% return {milliseconds :: pos_integer(), iso8601 :: binary()}
get_sleep_time() ->
    case db:squery(queries:earliest_runat()) of
        {ok, _, []} ->
            % there is no next earliest reminder, check again in 1 minute
            {MegaSecs, Secs, MicroSecs} = erlang:timestamp(),
            Next = {MegaSecs, Secs + 60, MicroSecs},
            {?ONE_MINUTE, iso8601:format(Next)};

        {ok, _, [Next]} ->
            Diff = utils:utc_diff(Next, iso8601:format(erlang:timestamp())),
            {Diff, Next}
    end.