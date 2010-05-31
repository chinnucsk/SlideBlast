-module (deck).
-include ("caster.hrl").
-export ([load_deck/1, save_deck/2]).
-export ([load_blob/1, save_blob/2]).
-export ([copy/3]).
-define (DECK_BUCKET, <<"caster_deck">>).
-define (BLOB_BUCKET, <<"blob_bucket">>).

get_riak_client() ->
    case get(riak_client) of
        Pid when is_pid(Pid) ->
            case is_process_alive(Pid) of
                true  -> Pid;
                false -> new_riak_client()
            end;
        _ ->
            new_riak_client()
    end.

new_riak_client() ->
    RiakIP = get_env(riak_ip, "127.0.0.1"),
    RiakPort = get_env(riak_port, 8087),
    case riakc_pb_socket:start_link(RiakIP, RiakPort) of
        {ok, Pid} -> 
            put(riak_client, Pid),
            Pid;
        Other ->
            throw(Other)
    end.

copy(DeckID, NewDeckID, AdminToken) 
when is_binary(DeckID), is_binary(NewDeckID), is_binary(AdminToken) ->
    Deck = load_deck(DeckID),
    NewDeck = Deck#deck { admin_token=AdminToken },
    save_deck(NewDeckID, NewDeck),
    ok.    

% Load a slide deck from Riak.
load_deck(DeckID) ->
    Pid = get_riak_client(),
    {ok, Obj} = riakc_pb_socket:get(Pid, ?DECK_BUCKET, DeckID),
    binary_to_term(riakc_obj:get_value(Obj)).

% Save a slide deck to Riak.
save_deck(DeckID, Deck) ->
    DeckB = term_to_binary(Deck),
    Pid = get_riak_client(),
    Obj1 = case riakc_pb_socket:get(Pid, ?DECK_BUCKET, DeckID) of
        {ok, Obj} -> riakc_obj:update_value(Obj, DeckB);
        _         -> riakc_obj:new(?DECK_BUCKET, DeckID, DeckB)
    end,
    riakc_pb_socket:put(Pid, Obj1).

% Load a blob from Riak. This can be an image, thumbnail, or text file.
load_blob(BlobID) ->
    Pid = get_riak_client(),
    {ok, Obj} = riakc_pb_socket:get(Pid, ?BLOB_BUCKET, BlobID),
    riakc_obj:get_value(Obj).

% Save a blob to Riak.
save_blob(BlobID, Blob) when is_binary(Blob) ->
    Pid = get_riak_client(),
    Obj1 = case riakc_pb_socket:get(Pid, ?BLOB_BUCKET, BlobID) of
        {ok, Obj} -> riakc_obj:update_value(Obj, Blob);
        _         -> riakc_obj:new(?BLOB_BUCKET, BlobID, Blob)
    end,
    riakc_pb_socket:put(Pid, Obj1).

get_env(Key, Default) ->
    case application:get_env(nitrogen, Key) of
        {ok, Value} -> Value;
        _ -> throw({env_not_defined, nitrogen, Key})
    end.

