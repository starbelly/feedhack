-module(feedhack_db).

-behaviour(gen_server).

-export([start_link/0, stop/1]).

-export([handle_call/3, handle_info/2, handle_cast/2, init/1]).

-export([terminate/2, code_change/3]).

-export([update/1, index/0, get/1]).

% Client
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop(Pid) ->
    gen_server:stop(Pid).

index() ->
    [{top, Top}] = ets:lookup(?MODULE, top),
    {ok, Top}.

get(Id) ->
    case ets:lookup(?MODULE, Id) of
        [{Id, Item}] ->
            Item;
        _ ->
          undefined
    end.

update({top, Items}) ->
    gen_server:call(?MODULE, {update_top, Items}).

% Server
init([]) ->
    Opts = [named_table, protected, {write_concurrency, false}, {read_concurrency, true}],
    ?MODULE = ets:new(?MODULE, Opts),
    ets:insert(?MODULE, {top, []}),
    {ok, {}}.

handle_call({update_top, Items}, _From, State) ->
    ets:insert(?MODULE, {top, Items}),
    ets:insert(?MODULE, Items),
    {reply, ok, State}.

handle_cast(_, State) ->
    {ok, State}.

handle_info(_, State) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
