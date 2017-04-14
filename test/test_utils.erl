-module(test_utils).

-export([urls/0]).

urls() ->
    Base = "http://localhost:8080",

    [{base, Base},
     {signup_endpoint, Base ++ "/api/signup"}].