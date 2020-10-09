-module(feedhack_agg).

-behaviour(gen_server).

-export([start_link/0, stop/1]).

-export([handle_call/3, handle_info/2, handle_cast/2, init/1]).

-export([terminate/2, code_change/3]).

-define(INTERVAL, 60000 * 5). % Five minutes

% Client
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [{interval, ?INTERVAL}], []).

stop(Pid) ->
    gen_server:stop(Pid).

% Server
init([{interval, Interval}]) ->
    %%_Tid = ets:new(?MODULE, [named_table, public, {write_concurrency, true}]),
    self() ! poll,
    {ok, {sys_now(), Interval}}.

handle_call(_, State, _) ->
    {noreply, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(poll, {Start, Interval} = State) ->
    maybe_poll(),
    erlang:send_after(next(Start, Interval), self(), poll),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

sys_now() ->
    erlang:monotonic_time(millisecond).

next(Start, Interval) ->
    Interval - (sys_now() - Start) rem Interval.

maybe_poll() ->
    feedhack:update().
