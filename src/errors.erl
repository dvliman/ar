-module(errors).

-export([response/2]).

parse_error(missing_orgid)       -> {400, bad_request};
parse_error(transaction_aborted) -> {400, bad_request};
parse_error(missing_required_fields) -> {400, bad_request};
parse_error(account_create_failure)  -> {500, server_error};
parse_error(_) -> {500, internal_server_error}.

response(Reason, Req) ->
    {StatusCode, Error} = parse_error(Reason),

    Payload = jiffy:encode({[
        {statuscode, StatusCode},
        {reason, Reason},
        {error, Error}]}),

    Req1 = cowboy_req:delete_resp_header(<<"content-type">>, Req),
    Req2 = cowboy_req:set_resp_header(<<"Content-Type">>, <<"application/json">>, Req1),
    Req3 = cowboy_req:set_resp_body(Payload, Req2),
    Req4 = cowboy_req:reply(StatusCode, Req3),
    Req4.
