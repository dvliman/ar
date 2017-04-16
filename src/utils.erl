-module(utils).

-export([interpolate/2]).

interpolate(Pattern, Args) when length(Args) > 0 ->
    lists:flatten(io_lib:format(Pattern, Args)).