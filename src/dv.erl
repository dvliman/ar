-module(dv).
-behavior(application).

-export([start/0, start/2,
         stop/0, stop/1]).

start() ->
    application:ensure_started(dv_app).

start(_Type, _Args) ->
    ok.

stop() ->
    ok.

stop(_State) ->
    ok.
