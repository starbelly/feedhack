-module(feedhack_client).

-export([request/5]).

-type method() :: get | post | put | patch | delete.
-type uri() :: binary() | string().
-type headers() :: list().
-type body() :: binary().
-type options() :: map().
-type status() :: non_neg_integer().

-callback request(method(), uri(),  headers(), body(), options()) ->
    {ok, status(), headers(), binary()} | {error, term()}.


-spec request(options(), method(), uri(), headers(), body()) ->
    {ok, {status(), headers(), binary()}} | {error, term()}.
request(Config, Method, URI, Headers, Body) ->
    Adapter = maps:get(adapter, Config),
    AdapterConfig = maps:get(adapter_config, Config, #{}),
    {ok, _Status, _H, ResBody} = Adapter:request(Method, URI, Headers, Body, AdapterConfig),
    {ok, ResBody}.
