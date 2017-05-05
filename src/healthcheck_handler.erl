-module(healthcheck_handler).

-export([init/2]).

init(Req, Opts) ->
    NewReq = cowboy_req:reply(200,
        #{<<"Content-Type">> => <<"application/json">>},
        jiffy:encode(#{status => ok, time => utils:now()}),
        Req),
    
    {ok, NewReq, Opts}.

