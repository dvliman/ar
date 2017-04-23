-module(dv_sup).
-behavior(supervisor).
-include("dv.hrl").

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Db = {db, {db, start_link, [?config(db)]},
        transient, 1000, worker, [db]},

    Scheduler = {scheduler, {scheduler, start_link, [[]]},
        permanent, 1000, worker, [scheduler]},

    {ok, {{one_for_all, 10, 30}, [Db, Scheduler]}}.
