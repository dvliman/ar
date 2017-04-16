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
        <<"website">>   := Website,
        <<"plan">>      := Plan},
      <<"account">> := #{
        <<"fname">>  := Fname,
        <<"lname">>  := Lname,
        <<"phone">>  := Phone,
        <<"email">>  := Email,
        <<"street">> := Street,
        <<"state">>  := St,
        <<"zipcode">>  := Zipcode}} = Payload,

%%    Query = utils:interpolate(
%%        <<"BEGIN;
%%            INSERT INTO orgs (name, subdomain, website, plan)
%%                VALUES ('~s', '~s', '~s', '~s');
%%            INSERT INTO accounts (orgid, fname, lname, phone, email, street, state, zipcode)
%%                VALUES (currval('orgs_id_seq'), '~s', '~s', '~s', '~s', '~s', '~s', '~s');
%%           COMMIT;">>,
%%        [Name, Subdomain, Website, Plan,
%%         Fname, Lname, Phone, Email, Street, St, Zipcode]),

    {ok, S1} = epgsql:parse(db:conn(), "INSERT INTO orgs (name, subdomain, website, plan)
        VALUES ('$1', '$2', '$3', '$4')", [text, text, text, text]),
    {ok, S2} = epgsql:parse(db:conn(), "INSERTO INTO accounts (orgid, fname, lname, phone, email, street, state, zipcode)
        VALUES (currval('orgs_id_seq'), '$1', '$2', '$3', '$4', '$5', '$6', '$7')", [text, text, text, text, text, text, text]),
    Result = epgsql:execute_batch(db:conn(),
        [{S1, [Name, Subdomain, Website, Plan]}],
        [{S2, [Fname, Lname, Phone, Email, Street, St, Zipcode]}]),
    ct:pal("result:~p", [Result]),
    {true, Req1, State}.