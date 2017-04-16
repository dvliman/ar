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
        <<"zipcode">>  := Zipcode}} = Payload,

    Query = utils:interpolate(
        <<"BEGIN;
            INSERT INTO orgs (name, subdomain, website, plan)
                VALUES ('~s', '~s', '~s', 'free');
            INSERT INTO accounts (orgid, fname, lname, phone, email, street, state, zipcode)
                VALUES (currval('orgs_id_seq'), '~s', '~s', '~s', '~s', '~s', '~s', '~s');
            SELECT id, name, subdomain, website, plan
                FROM orgs WHERE id = currval('orgs_id_seq');
            SELECT id, orgid, fname, lname, phone, email, street, state, zipcode
                FROM accounts WHERE id = currval('accounts_id_seq');
           COMMIT;">>,
        [Name, Subdomain, Website,
         Fname, Lname, Phone, Email, Street, St, Zipcode]),

    case epgsql:squery(db:conn(), Query) of
        [{ok, [], []},
         {ok, 1}, {ok, 1},
         {ok, Columns1, Rows1},
         {ok, Columns2, Rows2},
         {ok, [], []}] ->
            Org     = utils:extract_resultset(Columns1, Rows1),
            Account = utils:extract_resultset(Columns2, Rows2),

            Reply = jiffy:encode({[{org, {Org}}, {account, {Account}}]}),

            Req2 = cowboy_req:set_resp_body(Reply, Req1),
            {true, Req2, State};
        Reason ->
            ct:pal("errout transaction"),
            {true, Req1, State}
    end.
