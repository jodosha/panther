HTTP2_SETTINGS = {
  type: :settings,
  stream: 0,
  payload: [
    [:settings_max_concurrent_streams, 10].freeze,
    [:settings_initial_window_size, 0x7fffffff].freeze,
  ].freeze,
}.freeze


HTTP2_DATA = {
  type: :data,
  flags: [:end_stream].freeze,
  stream: 1,
  payload: 'text'.freeze,
}.freeze

HTTP2_HEADERS = {
  type: :headers,
  flags: [:end_headers].freeze,
  stream: 1,
  payload: HTTP2::Header::Compressor.new.encode([%w(a b)]).freeze,
}.freeze
