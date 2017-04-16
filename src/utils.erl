-module(utils).

-export([interpolate/2, extract_resultset/2]).

interpolate(Pattern, Args) when length(Args) > 0 ->
    lists:flatten(io_lib:format(Pattern, Args)).

extract_resultset(Columns, Rows) ->
    C = lists:map(fun extract_column/1, Columns),
    R = extract_rows(Rows),
    lists:zip(C, R).

extract_column({column, Name, _, _, _, _}) ->
    Name.
extract_rows([Tuple]) ->
    tup2list(Tuple).

% {a, b, c, ..} -> [a, b, c, ..]
tup2list(Tuple) ->
    tup2list(Tuple, 1, tuple_size(Tuple)).
tup2list(Tuple, Pos, Size) when Pos =< Size ->
    [element(Pos,Tuple) | tup2list(Tuple, Pos+1, Size)];
tup2list(_Tuple,_Pos,_Size) -> [].