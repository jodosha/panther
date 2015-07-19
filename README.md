# Panther

Experimental HTTP/2 server for Rack.

**This is NOT production ready, just a code spike.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'panther'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install panther

## Usage

`bundle exec rackup --server=panther config.ru -O key=config/key.pem -O cert=config/cert.pem`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jodosha/panther.

