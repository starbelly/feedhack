%%%-------------------------------------------------------------------
%% @doc feedhack_api public API
%% @end
%%%-------------------------------------------------------------------

-module(feedhack_api_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    feedhack_api_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
