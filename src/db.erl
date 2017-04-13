-module(db).
-behavior(gen_server).

-record(state, {status, conn}).

-export([init/1,
         start_link/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-export([conn/0]).

conn() ->
    gen_server:call(self(), conn).

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

init(Args) ->
    process_flag(trap_exit, true),

    case epgsql:connect(Args) of
        {ok, C} ->
            {ok, #state{status = connected, conn = C}};
        {error, Reason} ->
            {ok, #state{status = Reason, conn = undefined}}
    end.

handle_call(conn, _From, #state{status = connected, conn = C} = State) ->
    {reply, C, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

% upstream postgres connection goes down, restart this
% will try 10 times and after that, fail completely
handle_info({'EXIT', _, _}, State) ->
    {stop, postgres_conn_closed, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
