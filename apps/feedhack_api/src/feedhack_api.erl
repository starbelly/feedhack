-module(feedhack_api).
-export([handle/2, handle_event/3]).

-include_lib("elli/include/elli.hrl").

-behaviour(elli_handler).

-define(UNSUPPORTED_MIME_BODY, to_json(#{error => <<"Unsupported Media Type">>})).
-define(UNSUPPORTED_MIME, {415, [{<<"Content-type">>,  <<"application/json">>}], ?UNSUPPORTED_MIME_BODY}).

-define(MIME_TYPES, #{
            json                              => <<"application/json">>,
            <<"application/json">>            => json
         }).

%-spec init(elli:req(), elli_handler:callback_args()) -> elli_handler:result().
init(Req, Args) ->
    Method = case elli_request:get_header(<<"Upgrade">>, Req) of
        <<"websocket">> ->
            init_ws(elli_request:path(Req), Req, Args);
        _ ->
            ignore
    end.

init_ws([<<"ws">>], _Req, _Args) ->
    {ok, handover};
init_ws(_, _, _) ->
    ignore.

handle(Req, Args) ->
    case elli_request:get_header(<<"Upgrade">>, Req) of
        <<"websocket">> ->
            handle(websocket, elli_request:path(Req), Req, Args);
        _ ->

            case valid_mime(Req) of
                ok ->
                    handle(Req#req.method, elli_request:path(Req), Req);
                error ->
                    ?UNSUPPORTED_MIME
            end
    end.


handle('websocket', [<<"ws">>], Req, Args) ->
    elli_websocket:upgrade(Req, Args),
    {<<"1000">>, <<"Closed">>};
handle('GET', [<<"ws">>], _Req, _Args) ->
    {200, [], <<"Use an upgrade request">>};
handle(_,_,_,_) ->
    ignore.

handle('GET', [<<"api">>, <<"v1">>, <<"top">>], Req) ->
    Page = elli_request:get_arg(<<"page">>, Req, <<"all">>),
    {ok, Json} = feedhack:index(),
    respond_with(200, Req, Json);

handle('GET', [<<"api">>, <<"v1">>, <<"top">>, Id], Req) ->
    case get_item(binary_to_integer(Id)) of
        undefined ->
            respond_with(404, Req, <<"">>);
        Body ->
            respond_with(200, Req, Body)
    end;

handle(_, _, Req) ->
    respond_with(404, Req, <<"">>).

handle_event(_Event, _Data, _Args) ->
    ok.

%% Helpers
valid_mime(Req) ->
    case elli_request:get_header(<<"Accept">>, Req) of
        <<"application/json">> ->
            ok;
        _ ->
            error
    end.

get_index(Page) ->
    feedhack:index(Page).

get_item(Id) ->
    feedhack:get(Id).

respond_with(Status, Req, Body) ->
    {Status, [{<<"Content-type">>, send_as(Req)}], Body}.

client_accepts(Req) ->
    maps:get(elli_request:get_header(<<"Accept">>, Req), ?MIME_TYPES).

send_as(Req) ->
    maps:get(client_accepts(Req), ?MIME_TYPES).

to_json(Data) ->
    jsone:encode(Data).
