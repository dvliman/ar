-module(contact_SUITE).

-export([all/0,
         bootstrap/1]).

all() -> [bootstrap].

bootstrap(_) ->
    ok.