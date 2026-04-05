//// Gleam bindings for Brotli compression.
//// 
//// Brotli is a general-purpose compression algorithm developed by Google that
//// offers compression ratios comparable to the best currently available 
//// methods. It's particularly effective for web content and is supported 
//// natively by all modern browsers.
//// 
//// Brotli compression is most effective for data larger than ~1KB. For very 
//// small data, the compression overhead may result in larger output.

/// Compresses data using Brotli with default settings. For custom compression 
/// settings, use `encode_with`. Returns the compressed data or error if 
/// compression fails.
@external(erlang, "brot_ffi", "encode")
pub fn encode(data: BitArray) -> Result(BitArray, Nil)

/// Decompresses Brotli-compressed data. Returns the decompressed original data
/// or error if decompression fails.
@external(erlang, "brot_ffi", "decode")
pub fn decode(data: BitArray) -> Result(BitArray, Nil)

/// Compression mode that tunes the encoder for different types of content.
/// The mode affects how Brotli analyzes and compresses the input data.
pub type Mode {
  /// General-purpose compression suitable for any type of data. Use this when 
  /// you're unsure or have mixed content types.
  Generic
  /// Optimized for UTF-8 text compression. Provides better compression ratios 
  /// for natural language text.
  Text
  /// Optimized for font file compression, for example WOFF2 format. 
  /// Specifically tuned for the structure of font files.
  Font
}

/// Configuration options for Brotli compression. These options control the 
/// trade-offs between compression ratio, speed, and memory usage.
pub type Options {
  Options(
    /// Compression mode optimized for content type.
    mode: Mode,
    /// Compression quality level, from 0 to 11. Higher values produce better 
    /// compression but are slower. Levels 0-4 are fast, 5-9 are balanced, 
    /// 10-11 are for maximum compression.
    quality: Int,
    /// Base-2 logarithm of the sliding window size, from 10 to 24. Larger 
    /// windows can improve compression ratio but use more memory. Default is 22
    /// (4MB window). For `large_window` set to `True`, can go up to 24.
    window: Int,
    /// Maximum input block size, use 0 for automatic. If non-zero, splits input 
    /// into blocks of this size for processing.
    block_size: Int,
    /// Enable literal context modeling for better text compression. Slightly 
    /// slower but improves compression ratio for text.
    literal_context_modeling: Bool,
    /// Estimated total input size in bytes, use 0 if unknown. Helps the encoder 
    /// optimize memory allocation and compression strategy.
    size_hint: Int,
    /// Enable large window support, that allows to have window sizes of 
    /// 16MB-32MB.
    large_window: Bool,
    /// Number of postfix bits for distance codes, from 0 to 3. Advanced tuning 
    /// parameter. Use 0 unless you know what you're doing.
    npostfix: Int,
    /// Number of direct distance codes, from 0 to 120, must be divisible by 
    /// 1 << npostfix. Advanced tuning parameter. Use 0 unless you know what 
    /// you're doing.
    ndirect: Int,
    /// Starting byte offset for the stream, used in streaming compression. 
    /// Typically set to 0 for fresh compression.
    stream_offset: Int,
  )
}

/// Default compression options with balanced settings. Uses maximum 
/// compression, 4MB window, and generic mode. These defaults match the Brotli 
/// reference implementation.
///
/// Reference: https://github.com/google/brotli/blob/master/c/enc/encode.c#L681
pub const default_options = Options(
  mode: Generic,
  quality: 11,
  window: 22,
  block_size: 0,
  literal_context_modeling: True,
  size_hint: 0,
  large_window: False,
  npostfix: 0,
  ndirect: 0,
  stream_offset: 0,
)

/// Compresses data using Brotli with custom options. This allows fine-tuned 
/// control over compression parameters. Returns the compressed data or error
/// if fails.
@external(erlang, "brot_ffi", "encode_with")
pub fn encode_with(data: BitArray, options: Options) -> Result(BitArray, Nil)

/// Represents a streaming Brotli encoder. Use this for incremental compression 
/// of data that arrives in chunks or when you want to compress data without 
/// loading it all into memory at once.
pub type Encoder

/// Creates a new streaming encoder with default settings.
@external(erlang, "brotli_encoder", "new")
pub fn new_encoder() -> Encoder

/// Creates a new streaming encoder with custom options.
@external(erlang, "brot_ffi", "new_encoder_with")
pub fn new_encoder_with(options: Options) -> Encoder

/// Appends data to a streaming encoder and returns any available compressed 
/// output. The encoder may buffer data internally, so compressed output might 
/// not be available immediately for small inputs. Returns error if encoding
/// fails.
@external(erlang, "brot_ffi", "append_encoder")
pub fn append_encoder(encoder: Encoder, data: BitArray) -> Result(BitArray, Nil)

/// Checks if the encoder has finished processing and flushed all output. 
/// Returns `True` if encoding is complete and all output has been flushed, 
/// `False` otherwise.
@external(erlang, "brotli_encoder", "is_finished")
pub fn is_encoder_finished(encoder: Encoder) -> Bool

/// Finalizes the encoder and returns any remaining compressed output. This 
/// flushes all internal buffers and completes the compression stream. After 
/// calling this, the encoder is finished and should not be used further. 
/// Returns error if finishing fails.
@external(erlang, "brot_ffi", "finish_encoder")
pub fn finish_encoder(encoder: Encoder) -> Result(BitArray, Nil)

/// Appends final data to the encoder and immediately finishes compression. This 
/// is a convenience function that combines `append_encoder` and 
/// `finish_encoder`. Returns all remaining compressed output, or error if 
/// encoding or finishing fails.
@external(erlang, "brot_ffi", "finish_encoder_with")
pub fn finish_encoder_with(
  encoder: Encoder,
  data: BitArray,
) -> Result(BitArray, Nil)

/// Represents a streaming Brotli decoder. Use this for incremental 
/// decompression of data that arrives in chunks or when processing compressed 
/// streams.
pub type Decoder

/// Creates a new streaming decoder.
@external(erlang, "brotli_decoder", "new")
pub fn new_decoder() -> Decoder

/// Result type for streaming decompression operations.
pub type StreamOutcome {
  /// Decompression is complete. Contains the final decompressed output. No more 
  /// input data is expected.
  Done(BitArray)
  /// More input data is needed to continue decompression. Contains any 
  /// decompressed output produced so far. May be empty.
  More(BitArray)
}

/// Feeds compressed data to a streaming decoder and returns decompressed output.
/// The decoder processes data incrementally and indicates whether more input is 
/// needed. Returns error if decompression fails.
@external(erlang, "brot_ffi", "stream_decoder")
pub fn stream_decoder(
  decoder: Decoder,
  data: BitArray,
) -> Result(StreamOutcome, Nil)

/// Checks if the decoder has finished decompressing all data. Returns `True` if 
/// decompression is complete, `False` if more data is expected.
@external(erlang, "brotli_decoder", "is_finished")
pub fn is_decoder_finished(decoder: Decoder) -> Bool
