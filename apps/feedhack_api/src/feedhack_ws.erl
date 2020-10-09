-module(feedhack_ws).

-export([
         websocket_init/2,
         websocket_info/3,
         websocket_handle/3,
         websocket_handle_event/3
        ]).

-include_lib("elli/include/elli.hrl").

websocket_init(_Req, _Opts) ->
    feedhack_pubsub:subscribe(top),
    State = undefined,
    {ok, [], State}.

websocket_info(_Req, {push, Message}, State) ->
    {reply, Message, State};

websocket_info(_Req, Message, State) ->
    {ok, State}.

websocket_handle(_Req, _Message, State) ->
    {ok, State}.

websocket_handle_event(websocket_open, [_, _Version, _Compress], _) ->
    {ok, Json} = feedhack:index(),
    feedhack_pubsub:push(self(), {text, Json}),
    ok;

websocket_handle_event(websocket_close, [_, _Reason], _) -> ok;
websocket_handle_event(websocket_throw, [_Request, _Exception, _Stacktrace], _) -> ok;
websocket_handle_event(websocket_error, [_Request, _Exception, _Stacktrace], _) -> ok;
websocket_handle_event(websocket_exit, [_Request, _Exception, _Stacktrace], _) -> ok.
