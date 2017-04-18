-module(account_SUITE).

-export([all/0,
         invalid_orgid/1]).

all() -> [invalid_orgid].

invalid_orgid(_Config) ->
    Endpoint = proplists:get_value(account_create_endpoint, test_utils:urls()),

    Payload = #{account => #{
        orgid => 9999, % this shouldnt exist
        fname => utils:binhex(),
        lname => utils:binhex(),
        phone => utils:binhex(),
        email => utils:binhex(),
        street  => utils:binhex(),
        state   => utils:binhex(),
        zipcode => utils:binhex(),
        password => utils:binhex()}},

    {ok, "400", _, Body} = ibrowse:send_req(Endpoint, test_utils:headers(),
        post, jiffy:encode(Payload)),

    {[{<<"statuscode">>, 400},
      {<<"category">>, <<"bad_request">>},
      {<<"reason">>, <<"invalid_orgid">>}]} = jiffy:decode(Body).
