-module(test_utils).

-export([urls/0,
         test/1,
         headers/0]).

urls() ->
    Base = "http://localhost:8080",

    [{base, Base},
     {signup_endpoint,         Base ++ "/api/signup"},
     {contact_create_endpoint, Base ++ "/api/account/create"},
     {contact_delete_endpoint, Base ++ "/api/account/delete"}].

headers() ->
    [{<<"Content-Type">>, <<"application/json">>}].

test(Module) ->
    lists:foldl(
        fun(TestCase, Acc) ->
            Result = erlang:apply(Module, TestCase, [[]]),
            [{TestCase, Result} | Acc]
        end, [], erlang:apply(Module, all, [])).
