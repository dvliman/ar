-module(dv_app).
-behavior(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    cowboy:start_clear(http, 100, [{port, 8080}], #{
       env => #{dispatch => dispatch()}
    }),
    dv_sup:start_link().

stop(_State) ->
    ok.

dispatch() ->
    cowboy_router:compile([{'_', [
        {"/api/signup",         signup_handler, []},
        {"/api/account/create", account_create_handler, []},
        {"/api/account/delete", account_delete_handler, []}
    ]}]).
