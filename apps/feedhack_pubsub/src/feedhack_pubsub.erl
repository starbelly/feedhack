-module(feedhack_pubsub).

-export([subscribe/1, members/1, broadcast/2, push/2]).

broadcast(Topic, Message) ->
    All = members(Topic),
    lists:foreach(fun(Pid) -> push(Pid, Message) end, All).

push(Pid, Message) ->
    Pid ! {push, Message}.

subscribe(Topic) ->
    ok = pg2:create(Topic),
    pg2:join(Topic, self()).

members(Topic) ->
    ok = pg2:create(Topic),
    pg2:get_members(Topic).
