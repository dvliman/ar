-module(test_utils).

-export([urls/0,
         headers/0]).

urls() ->
    Base = "http://localhost:8080",

    [{base, Base},
     {signup_endpoint, Base ++ "/api/signup"}].

headers() ->
    [{<<"Content-Type">>, <<"application/json">>}].