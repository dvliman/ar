-module(dv_sup).
-behavior(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, DBConfig} = application:get_env(dv, db),

    DBSpec = {db, {db, start_link, [DBConfig]},
        transient, 1000, worker, [db]},

    {ok, {{one_for_all, 10, 30}, [DBSpec]}}.
