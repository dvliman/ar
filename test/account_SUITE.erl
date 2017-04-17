-module(account_SUITE).

-export([all/0,
         create_account_need_org/1]).

all() -> [create_account_need_org].

create_account_need_org(_Config) ->
    Endpoint = proplists:get_value(account_create_endpoint, test_utils:urls()),

    Payload = #{account => #{
        orgid => 9999,
        fname => utils:binhex(),
        lname => utils:binhex(),
        phone => utils:binhex(),
        email => utils:binhex(),
        street  => utils:binhex(),
        state   => utils:binhex(),
        zipcode => utils:binhex()}},

    Result = ibrowse:send_req(Endpoint, test_utils:headers(),
        post, jiffy:encode(Payload)),
    ct:pal("result:~p", [Result]).
