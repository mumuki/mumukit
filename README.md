# Mumukit

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mumukit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mumukit

## Usage

1. Create a new ruby project
2. Add mumukit as dependency
3. Add a test runner in lib/test_runner
4. Add a test compiler in lib/test_compiler
5. Add the following config.ru:
```ruby
require 'mumukit'

require_relative 'lib/test_compiler'
require_relative 'lib/test_runner'

run Mumukit::TestServerApp
```

And run as `bundle exec rackup`


## Contributing

1. Fork it ( https://github.com/[my-github-username]/mumuki/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
