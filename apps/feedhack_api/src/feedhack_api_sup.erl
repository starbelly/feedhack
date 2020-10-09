%%%-------------------------------------------------------------------
%% @doc feedhack_api top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(feedhack_api_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    WsConfig = [{handler, feedhack_ws}],
    Config = [{mods, [{feedhack_api, WsConfig}]}],
    ElliOpts = [{callback, elli_middleware}, {callback_args, Config}, {port, 3000}],
    ChildSpecs = [
                  #{id => feedhack_api,
                    start => {elli, start_link, [ElliOpts]},
                    type => worker,
                    restart => permanent
                   }
                 ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
