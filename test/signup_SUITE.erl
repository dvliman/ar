-module(signup_SUITE).

-export([all/0,
         bootstrap/1]).

all() -> [bootstrap].

% create 'org', 'account', and a 'calendar'; org plan is 'free'
bootstrap(_) ->
    Endpoint = proplists:get_value(signup_endpoint, test_utils:urls()),

    Payload = #{
        org => #{
            name      => utils:binhex(),
            subdomain => utils:binhex(),
            website   => utils:binhex()},
        account => #{
            fname => utils:binhex(),
            lname => utils:binhex(),
            phone => utils:binhex(),
            email => utils:binhex(),
            street  => utils:binhex(),
            state   => utils:binhex(),
            zipcode => utils:binhex()},
        calendar => #{
            name    => utils:binhex(),
            opening => 9,
            closing => 5,
            timeblock => 60,
            timezone  => utils:binhex()}},

    {ok, "200", _, Resp} = ibrowse:send_req(Endpoint,
        test_utils:headers(), post, jiffy:encode(Payload)),
    jiffy:decode(Resp).
