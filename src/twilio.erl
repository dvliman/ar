-module(twilio).

-define(FROM, <<"+16262437266">>).
-define(ACCOUNT_SID, "api-key").
-define(AUTH_TOKEN, "api-secret").
-define(ENDPOINT, "https://api.twilio.com/2010-04-01/Accounts/~s/Messages.json").

-export([accept/4]).

accept(Id, OrgId, To, Body) ->
    case ibrowse:send_req(endpoint(), headers(), post, body(To, Body)) of
        {ok, "201", _, _} ->
            db:squery(queries:mark_as_sent(), [Id]);

        {ok, _, _, Response} ->
            #{<<"message">> := Msg} = jiffy:decode(Response, [return_maps]),
%%            db:squery(queries:report_error(), [Id, OrgId, Id, <<"sms">>, Msg, utils:now()]);
            ct:pal("twilio-failure=~p", [Msg]);

        {error, Reason} ->
            Msg = term_to_binary(Reason),
            ct:pal("twilio-error=~p", [Msg])
%%            db:squery(queries:report_error(), [Id, OrgId, Id, <<"sms">>, Msg, utils:now()])
    end.

body(To, Body) ->
    lists:flatten(io_lib:format("From=~s&To=~s&Body=~s", [?FROM, To, Body])).

headers() ->
    [{basic_auth, {?ACCOUNT_SID, ?AUTH_TOKEN}},
     {<<"Content-Type">>, <<"application/x-www-form-urlencoded">>}].

endpoint() ->
    lists:flatten(io_lib:format(?ENDPOINT, [?ACCOUNT_SID])).
