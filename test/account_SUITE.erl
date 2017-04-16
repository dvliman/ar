-module(account_SUITE).

-export([all/0,
         happypath/1]).

all() -> [happypath].

happypath(_) ->
    ok.
