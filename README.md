[![Build Status](https://travis-ci.org/mumuki/mumukit.svg)](https://travis-ci.org/mumuki/mumukit)
[![Code Climate](https://codeclimate.com/github/mumuki/mumukit/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumukit)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumukit/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumukit)

# Mumukit

> Micro framework for quickly implement Mumuki runners

## Usage

### Installing

You usually add mumukit to an empty project. First you need to add it to your Gemfile:

```
gem 'mumukit', github: 'mumuki/mumukit', tag: 'v0.7.2'
```

or, if you want latest version:


```
gem 'mumukit', github: 'mumuki/mumukit', branch: 'master'
```

And then `bundle install`

### Adding basic components

The most basic mumukit components are:

* a test runner: lib/test_runner. It must be a class that implements at least a `run_test_command` method [Example](https://github.com/uqbar-project/mumuki-plunit-server/blob/master/lib/test_runner.rb)
* test compiler: lib/test_compiler. It must be a class that implements at least a `compile` method.  [Example](https://github.com/uqbar-project/mumuki-plunit-server/blob/master/lib/test_compiler.rb)

### Running

Mumukit comes wit Sinatra embedded. We recommend running it using a `config.ru` file:

```ruby
require 'mumukit'

require_relative 'lib/test_compiler'
require_relative 'lib/test_runner'

run Mumukit::TestServerApp
```

And run as `bundle exec rackup`

## Testing

You can unit test any runner developed with mumukit since you are just extending plain Ruby classes.

You can also do integration testing. There are two options:

* Running a local mumuki-platform instance
* Or using mumukit-bridge, wich is the standalone component that is used by the platform to interact with the runners. Here there is a test template: https://gist.github.com/flbulgarelli/defdc7adbd115481d4bc

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mumuki/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
