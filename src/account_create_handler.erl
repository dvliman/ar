-module(account_create_handler).
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

    #{<<"account">> := Payload} =
        jiffy:decode(Body, [return_maps]),

    case validate(Payload) of
        ok ->
            {true, Req1, State};
        Error ->
            Req2 = errors:response(Error, Req1),
            {true, Req2, State}
    end.

validate(Payload) ->
    Required = [atom_to_binary(X, utf8) || X <- (record_info(fields, account) -- [id])],

    case utils:intersection(Required, maps:keys(Payload)) of
        Required ->
            maps:fold(fun check/3, ok, Payload); % now check each attribute
        Intersected ->
            Missing = Required -- Intersected,
            {error, missing_required_fields, Missing}
    end.

check(<<"orgid">>, OrgId, ok) ->
    Query = utils:interpolate(<<"select exists (select id from orgs where id = ~b)">>, [OrgId]),

    case epgsql:squery(db:conn(), Query) of
        {ok, _, [{<<"t">>}]} -> ok;
        {ok, _, [{<<"f">>}]} -> {error, missing_orgid};
        Error ->
            ct:pal("account-create, validate-orgid:~p", [Error]),
            {error, account_create_failure}
    end;

check(_, _, ok)               -> ok;
check(_, _, {error, _} = Acc) -> Acc.