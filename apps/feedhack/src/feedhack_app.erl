%%%-------------------------------------------------------------------
%% @doc feedhack public API
%% @end
%%%-------------------------------------------------------------------

-module(feedhack_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    feedhack_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
