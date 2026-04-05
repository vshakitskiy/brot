-module(brot_ffi).

-export([options_to_map/1, encode/1, decode/1, encode_with/2, new_encoder_with/1,
         append_encoder/2, finish_encoder/1, finish_encoder_with/2, stream_decoder/2]).

options_to_map({options,
                Mode,
                Quality,
                Window,
                BlockSize,
                LiteralContextModeling,
                SizeHint,
                LargeWindow,
                NPostfix,
                NDirect,
                StreamOffset}) ->
    #{mode => Mode,
      quality => Quality,
      window => Window,
      block_size => BlockSize,
      literal_context_modeling => LiteralContextModeling,
      size_hint => SizeHint,
      large_window => LargeWindow,
      npostfix => NPostfix,
      ndirect => NDirect,
      stream_offset => StreamOffset}.

encode(Data) ->
    try
        case brotli:encode(Data) of
            {ok, EncodedData} ->
                {ok, EncodedData};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

decode(Data) ->
    try
        case brotli:decode(Data) of
            {ok, DecodedData} ->
                {ok, iolist_to_binary(DecodedData)};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

encode_with(Data, Options) ->
    try
        case brotli:encode(Data, options_to_map(Options)) of
            {ok, EncodedData} ->
                {ok, EncodedData};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

new_encoder_with(Options) ->
    brotli_encoder:new(options_to_map(Options)).

append_encoder(Encoder, Data) ->
    try
        case brotli_encoder:append(Encoder, Data) of
            {ok, EncodedData} ->
                {ok, iolist_to_binary(EncodedData)};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

finish_encoder(Encoder) ->
    try
        case brotli_encoder:finish(Encoder) of
            {ok, EncodedData} ->
                {ok, iolist_to_binary(EncodedData)};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

finish_encoder_with(Encoder, Data) ->
    try
        case brotli_encoder:finish(Encoder, Data) of
            {ok, EncodedData} ->
                {ok, iolist_to_binary(EncodedData)};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.

stream_decoder(Decoder, Data) ->
    try
        case brotli_decoder:stream(Decoder, Data) of
            {ok, DecodedData} ->
                {ok, {done, DecodedData}};
            {more, DecodedData} ->
                {ok, {more, DecodedData}};
            _ ->
                {error, nil}
        end
    catch
        _:_ ->
            {error, nil}
    end.
