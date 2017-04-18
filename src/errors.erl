-module(errors).

-export([response/2]).

parse_error({error, Error, Extra}) ->
    {StatusCode, Category} = parse_error(Error),
    {StatusCode, Category, Error, Extra};
parse_error({error, Error}) ->
    {StatusCode, Category} = parse_error(Error),
    {StatusCode, Category, Error};
parse_error(invalid_orgid) ->
    {400, bad_request};
parse_error(transaction_aborted) ->
    {400, bad_request};
parse_error(missing_required_fields) ->
    {400, bad_request};
parse_error(_) ->
    {500, internal_server_error}.

response(Error, Req) ->
    Reply =
        case parse_error(Error) of
            {StatusCode, Category, Reason} ->
                [{statuscode, StatusCode},
                 {category, Category},
                 {reason, Reason}];
            {StatusCode, Category, Reason, Extras} ->
                [{statuscode, StatusCode},
                 {category, Category},
                 {reason, Reason},
                 {extras, Extras}]
        end,
    StatusCode = proplists:get_value(statuscode, Reply),
    Req1 = cowboy_req:delete_resp_header(<<"content-type">>, Req),
    Req2 = cowboy_req:set_resp_header(<<"Content-Type">>, <<"application/json">>, Req1),
    Req3 = cowboy_req:set_resp_body(jiffy:encode({Reply}), Req2),
    Req4 = cowboy_req:reply(StatusCode, Req3),
    Req4.
