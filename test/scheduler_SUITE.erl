-module(scheduler_SUITE).

-export([all/0,
         minute_level/1]).

all() -> [minute_level].

minute_level(_) ->
    ok.
