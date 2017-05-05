-module(signup_SUITE).

-export([all/0,
         bootstrap/1]).

all() -> [bootstrap].

% create 'org', 'account', and a 'calendar'; org plan is 'free'
bootstrap(_) ->
    Endpoint = proplists:get_value(signup_endpoint, test_utils:urls()),

    Payload = #{org => #{
        name      => utils:binhex(),
        subdomain => utils:binhex(),
        website   => utils:binhex(),
        email     => utils:binhex(),
        password  => utils:binhex()}},

    {ok, "200", _, Resp} = ibrowse:send_req(Endpoint, test_utils:headers(),
        post, jiffy:encode(Payload)),
    jiffy:decode(Resp).
