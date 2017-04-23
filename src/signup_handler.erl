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

    Payload = jiffy:decode(Body, [return_maps]),
    #{<<"org">> := #{
        <<"name">>      := Name,
        <<"subdomain">> := Subdomain,
        <<"website">>   := Website},
      <<"account">> := #{
        <<"fname">>  := Fname,
        <<"lname">>  := Lname,
        <<"phone">>  := Phone,
        <<"email">>  := Email,
        <<"street">> := Street,
        <<"state">>  := St,
        <<"zipcode">>  := Zipcode},
      <<"calendar">> := #{
          <<"name">>    := Cname,
          <<"opening">> := Opening,
          <<"closing">> := Closing,
          <<"timeblock">> := Timeblock,
          <<"timezone">>  := Timezone}} = Payload,

    Params = [Name, Subdomain, Website,
        Fname, Lname, Phone, Email, Street, St, Zipcode,
        Cname, Opening, Closing, Timeblock, Timezone],

    case db:squery(queries:signup(), Params) of
        [{ok, [], []},
         {ok, 1}, {ok, 1}, {ok, 1},
         {ok, Columns1, Rows1},
         {ok, Columns2, Rows2},
         {ok, Columns3, Rows3},
         {ok, [], []}] ->
            Org      = utils:extract_resultset(Columns1, Rows1),
            Account  = utils:extract_resultset(Columns2, Rows2),
            Calendar = utils:extract_resultset(Columns3, Rows3),

            Reply = jiffy:encode({[
                {org, {Org}},
                {account, {Account}},
                {calendar, {Calendar}}]}),

            Req2 = cowboy_req:set_resp_body(Reply, Req1),
            {true, Req2, State};

        % transaction aborted, commit, and bad_request
        {error, {error, error, <<"25P02">>, _, _}} = Reason ->
            {ok, [], []} = db:squery(<<"commit;">>),
            Req2 = errors:response(transaction_aborted, Req1),
            {stop, Req2, State}

        % otherwise, crash with 500
    end.
