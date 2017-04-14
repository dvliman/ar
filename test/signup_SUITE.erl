-module(signup_SUITE).

-export([all/0,
         happypath/1]).

all() -> [happypath].

happypath(_) ->
    Endpoint = proplists:get_value(signup_endpoint, test_utils:urls()),

    Payload = jiffy:encode(
        {[{org, {[
            {name, <<"org-name">>}
        ]}},
          {account, {[
              {name, <<"account-name">>}
        ]}}]}),
    Result = ibrowse:send_req(Endpoint, [], post, Payload),
    timer:sleep(1000).
