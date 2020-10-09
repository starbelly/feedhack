-module(feedhack).

-export([get/1, index/0, index/1, fetch/0, fetch/1, update/0]).

%% Our HN stories are stored as JSON so we simply need to form a list
%% and avoid double encoding.
-define(LEFT_BRACE, <<"[">>).
-define(RIGHT_BRACE, <<"]">>).
-define(COMMA, <<",">>).
-define(NEW_LINE, <<"\n">>).


get(Id) -> feedhack_db:get(Id).

index() -> index(<<"all">>).

index(<<"all">>) ->
    {ok, Index} = feedhack_db:index(),
    {ok, Top} = to_string(Index),
    {ok, Top};

index(Page) ->
    PageNum = binary_to_integer(Page),
    case PageNum of
        N when N =< 5 ->
            {ok, Index} = feedhack_db:index(),
            Index1 = lists:sublist(Index, 10 * PageNum, 10),
            {ok, Json} = to_string(Index1),
            {ok, Json};
        _ ->
            %% TODO : Maybe return an error
            {ok, <<"[]">>}
    end.

to_string([]) -> {ok, <<"[]\n">>};

to_string(Index) ->
    Items = lists:foldl(fun({_Id, Json}, Acc) -> <<Acc/binary, Json/binary, ?COMMA/binary>> end, <<"">>, Index),
    Bin = binary:part(Items, 0, byte_size(Items) - 1),
    Json = <<?LEFT_BRACE/binary, Bin/binary, ?RIGHT_BRACE/binary>>,
    {ok, Json}.

-spec fetch() -> {ok, list()} | term().
fetch() ->
    fetch(50).

fetch(N) ->
    URI = "https://hacker-news.firebaseio.com/v0/topstories.json?limitToFirst="
    ++ integer_to_list(N)
    ++ "&orderBy=%22$key%22",
    _H = [{"X-Firebase-Decoding", "1"}],
    {ok, Items} = feedhack_client:request(#{adapter => feedhack_client_hackney}, get, URI, [], <<>>),
    {ok, Fetched} = get_items(Items),
    {ok, Fetched}.

update() ->
    {ok, Items} = feedhack:fetch(),
    {ok, Old} = feedhack_db:index(),
    New = Items -- Old,
    feedhack_db:update({top, Items}),
    case New of
        [] ->
            {ok, New};
        _ ->
            feedhack_pubsub:broadcast(top, {text, to_string(New)}),
            {ok, New}
    end.

-spec get_items(list()) -> {ok, list()}.
get_items(Items) ->
    Fetched = lists:map(fun(Id) -> {Id, Bin} = get_item(Id), {Id, Bin} end, Items),
    {ok, Fetched}.

-spec get_item(non_neg_integer()) -> {non_neg_integer(), binary()}.
get_item(Id) ->
    ItemPath =  <<"https://hacker-news.firebaseio.com/v0/item/">>,
    BinId = integer_to_binary(Id),
    Ext = <<".json">>,
    URI = <<ItemPath/binary, BinId/binary, Ext/binary>>,
    Opts = [{pool, my_pool}, {ssl_options, [{versions, ['tlsv1.2']}]}],
    {ok, _StatusCode, _RespHeaders, ClientRef} = hackney:request(get, URI, [], "", Opts),
    {ok, RespBody} = hackney:body(ClientRef),
    {Id, RespBody}.
