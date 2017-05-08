-module(contact_create_handler).
-include("dv.hrl").

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

    #{<<"contact">> := Payload} =
        jiffy:decode(Body, [return_maps]),

    case validate(Payload) of
        ok ->
            Inserts = db:squery(queries:new_contact(), []),
            {true, Req1, State};
        Error ->
            Req2 = errors:response(Error, Req1),
            {stop, Req2, State}
    end.

validate(_) -> ok.
%%validate(Payload) ->
%%    Required = ?required_fields(contact),
%%
%%    case utils:intersection(Required, maps:keys(Payload)) of
%%        Required ->
%%            maps:fold(fun check/3, ok, Payload); % now check each attribute
%%        Intersected ->
%%            Missing = Required -- Intersected,
%%            {error, missing_required_fields, hd(Missing)}
%%    end.
%%
%%check(<<"orgid">>, OrgId, ok) ->
%%    case db:squery(queries:org_exists(), [OrgId]) of
%%        {ok, _, [{<<"t">>}]} -> ok;
%%        {ok, _, [{<<"f">>}]} -> {error, invalid_orgid}
%%    end;
%%
%%check(_, _, ok)               -> ok;
%%check(_, _, {error, _} = Acc) -> Acc.