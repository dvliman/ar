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

-export([squery/1, squery/2]).

squery(Query) ->
    gen_server:call(?MODULE, {squery, Query}).

squery(Query, Params) ->
    gen_server:call(?MODULE, {squery, Query, Params}).

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

handle_call(conn, _, #state{status = connected, conn = C} = State) ->
    {reply, C, State};

handle_call({squery, Query}, _, #state{status = connected, conn = C} = State) ->
    Reply = epgsql:squery(C, Query),
    {reply, Reply, State};

handle_call({squery, Query, Params}, _, #state{status = connected, conn = C} = State) ->
    Reply = epgsql:squery(C, utils:interpolate(Query, Params)),
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

% upstream postgres connection goes down, crash & restart
% retry 10 times until supervisor reach max intensity
handle_info({'EXIT', _, _}, State) ->
    {stop, postgres_conn_closed, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
