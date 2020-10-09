-module(feedhack_client_hackney).
-behaviour(feedhack_client).
-export([request/5]).

request(Method, URI, ReqHeaders, Body, Options) ->
    Opts = maps:to_list(Options),
    Opts1 = Opts ++ [{pool, my_pool}, {ssl_options, [{versions, ['tlsv1.2']}]}],
    {ok, StatusCode, RespHeaders, ClientRef} = hackney:request(Method, URI, ReqHeaders, Body, Opts1),
    {ok, RespBody} = hackney:body(ClientRef),
    Json = jsone:decode(RespBody),
    {ok, StatusCode, RespHeaders, Json}.
