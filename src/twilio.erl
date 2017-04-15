-module(twilio).

-define(FROM, <<"+16262437266">>).
-define(ACCOUNT_SID, "ACf2a601bba33d7da5604ae0f85e693834").
-define(AUTH_TOKEN, "ebf6da29fc920a409de7578ea6774e93").
-define(ENDPOINT, "https://api.twilio.com/2010-04-01/Accounts/~s/Messages.json").

-export([send/2]).

send(To, Body) when is_binary(To), is_binary(Body) ->
    case ibrowse:send_req(endpoint(), headers(), post, body(To, Body)) of
        {ok, "201", _, _} ->
            sent;
        {ok, StatusCode, _, ResponseBody} ->
            ct:pal("twilio:send, to:~p, body:~p, status-code:~p, response-body:~p",
                [To, Body, StatusCode, ResponseBody]),
            not_sent;
        {error, Reason} ->
            ct:pal("twilio:send, to:~p, body:~p, reason:~p",
                [To, Body, Reason]),
            not_sent
    end.

body(To, Body) ->
    lists:flatten(io_lib:format("From=~s&To=~s&Body=~s", [?FROM, To, Body])).

headers() ->
    [{basic_auth, {?ACCOUNT_SID, ?AUTH_TOKEN}},
     {<<"Content-Type">>, <<"application/x-www-form-urlencoded">>}].

endpoint() ->
    lists:flatten(io_lib:format(?ENDPOINT, [?ACCOUNT_SID])).