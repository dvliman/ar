-module(signup_SUITE).

-export([all/0,
    happypath/1]).

all() -> [happypath].

happypath(_) ->
    Endpoint = proplists:get_value(signup_endpoint, test_utils:urls()),
    Payload = #{
        org => #{
            name      => <<"org-name">>,
            subdomain => <<"org-subdomain">>,
            website   => <<"org-website">>,
            plan      => <<"free">>},
        account => #{
            fname => <<"account-fname">>,
            lname => <<"account-lname">>,
            phone => <<"+17142532851">>,
            email => <<"limanoit@gmail.com">>,
            street   => <<"undefined">>,
            state    => <<"undefined">>,
            zipcode  => <<"undefined">>}},
    Result = ibrowse:send_req(Endpoint, test_utils:headers(), post, jiffy:encode(Payload)),
    ct:pal("result:~p", [Result]).
