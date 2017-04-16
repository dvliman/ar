-module(account_create_handler).

-export([init/2, allowed_methods/2,
         content_types_accepted/2,
         process/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, process}], Req, State}.

process(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Payload = jiffy:decode(Body, [return_maps]),
    ct:pal("payload:~p", [Payload]),
    {true, Req, State}.