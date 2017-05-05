-module(signup_handler).

-export([init/2, allowed_methods/2,
         content_types_accepted/2]).
-export([signup/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, signup}], Req, State}.

signup(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),

    #{<<"org">> := #{
        <<"name">>      := Name,
        <<"subdomain">> := Subdomain,
        <<"website">>   := Website,
        <<"email">>     := Email,
        <<"password">>  := Password}} = jiffy:decode(Body, [return_maps]),

    Params = [Name, Subdomain, Website,
              Email, Password, utils:now()],

    case db:squery(queries:signup(), Params) of
        [{ok, [], []},
         {ok, 1},
         {ok, Columns, Rows},
         {ok, [], []}] ->
            Result = utils:extract_resultset(Columns, Rows),
            Reply  = jiffy:encode({[{org, {Result}}]}),
            Req2 = cowboy_req:set_resp_body(Reply, Req1),

            {true, Req2, State};

        % transaction aborted, commit, and bad_request
        {error, {error, error, <<"25P02">>, _, _}} = Reason ->
            {ok, [], []} = db:squery(<<"commit;">>),
            Req2 = errors:response(transaction_aborted, Req1),
            {stop, Req2, State}

        % otherwise, crash with 500
    end.
