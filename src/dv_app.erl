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
        {"/api/contact.create", contact_create_handler, []},
        {"/api/contact.delete", contact_delete_handler, []}
    ]}]).
