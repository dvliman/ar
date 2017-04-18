-module(test_utils).

-export([urls/0,
         headers/0]).

urls() ->
    Base = "http://localhost:8080",

    [{base, Base},
     {signup_endpoint,         Base ++ "/api/signup"},
     {account_create_endpoint, Base ++ "/api/account/create"},
     {account_delete_endpoint, Base ++ "/api/account/delete"}].

headers() ->
    [{<<"Content-Type">>, <<"application/json">>}].