-module(bloom).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

-define(BLOOM_SIZE, 32).
-define(BLOOM_HASH_RANGE, 4294967296).
-define(INIT_BIN, <<0:?BLOOM_SIZE/little-unsigned-integer>>).
-define(HASH_SET, [fun erlang:phash/2, fun erlang:phash2/2]).

%% escript Entry point
main(_Args) ->
    KeySet = [hello, "world", 54321],
    Hashes = lists:map(fun (K) ->
                               hash_key(K, ?HASH_SET)
                       end, KeySet),
    io:format("hashes=~w~n", [Hashes]),
    Bloom = lists:foldl(fun bin_or/2, ?INIT_BIN, Hashes),
    io:format("~w~n", [Bloom]),

    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

hash_key(Key, Hashes) ->
    lists:foldl(fun (Hash, Bin) ->
                        H = apply(Hash, [Key, ?BLOOM_HASH_RANGE]),
                        H2 = <<H:?BLOOM_SIZE/little-unsigned-integer>>,
                        bin_or(H2, Bin)
                end, ?INIT_BIN, Hashes).

bin_or(A, B) ->
    <<V1:?BLOOM_SIZE/little-unsigned-integer>> = A,
    <<V2:?BLOOM_SIZE/little-unsigned-integer>> = B,
    V3 = V1 bor V2,
    <<V3:?BLOOM_SIZE/little-unsigned-integer>>.
