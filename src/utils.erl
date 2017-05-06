-module(utils).

-define(GREGORIAN_SECONDS, 62167219200). % Jan 1, 1970

-export([interpolate/2,
         intersection/2,
         extract_resultset/2,
         uuid/0, binuuid/0, binhex/0,
         datetime_to_timestamp/1,
         utc_diff/2,
         now/0,
         drop_secs/1]).

interpolate(Pattern, Args) when length(Args) > 0 ->
    lists:flatten(io_lib:format(Pattern, Args)).

intersection(L1, L2) ->
    lists:filter(fun(X) -> lists:member(X, L2) end, L1).

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

uuid() ->
    uuid:uuid_to_string(uuid:get_v4()).

binuuid() ->
    list_to_binary(uuid()).

binhex() ->
    base64:encode(binuuid()).

% calendar:datetime() to erlang:timestamp()
datetime_to_timestamp(DateTime) ->
    Seconds = calendar:datetime_to_gregorian_seconds(DateTime) - ?GREGORIAN_SECONDS,
    {Seconds div 1000000, Seconds rem 1000000, 0}.

% iso8601 - iso8601 = diff in milliseconds
utc_diff(Larger, Smaller) ->
    Larger1  = datetime_to_timestamp(iso8601:parse(Larger)),
    Smaller1 = datetime_to_timestamp(iso8601:parse(Smaller)),

    Microseconds = timer:now_diff(Larger1, Smaller1),
    trunc(Microseconds div 1000).

now() ->
    iso8601:format(erlang:timestamp()).

drop_secs(Utc) ->
    {Date, {Hour, Minute, _}} = iso8601:parse(Utc),
    iso8601:format({Date, {Hour, Minute, 00}}).
