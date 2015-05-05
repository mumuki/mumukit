[![Build Status](https://travis-ci.org/uqbar-project/mumukit.svg)](https://travis-ci.org/uqbar-project/mumukit)
[![Code Climate](https://codeclimate.com/github/uqbar-project/mumukit/badges/gpa.svg)](https://codeclimate.com/github/uqbar-project/mumukit)
[![Test Coverage](https://codeclimate.com/github/uqbar-project/mumukit/badges/coverage.svg)](https://codeclimate.com/github/uqbar-project/mumukit)

# Mumukit

Gem for quickly implement mumuki runners

## Usage

1. Create a new ruby project: 
    1. create an empty directory
    2. add an empty Gemfile - you can use bundle init
    3. add a Rakefile if you want - usefull for running tests
    4. and a .ruby-version, so that tools like rvm or rbenv know the version of ruby
2. Add mumukit as dependency in the Gemfile: `gem 'mumukit', github: 'uqbar-project/mumukit', tag: 'v0.1.0'`
3. Add a test runner in lib/test_runner. It must be a class that at implements at least a `run_test_command` method [Example](https://github.com/uqbar-project/mumuki-plunit-server/blob/master/lib/test_runner.rb)
4. Add a test compiler in lib/test_compiler. It must be a class that at least implements a `compile` method.  [Example](https://github.com/uqbar-project/mumuki-plunit-server/blob/master/lib/test_compiler.rb)
5. Add the following config.ru:
```ruby
require 'mumukit'

require_relative 'lib/test_compiler'
require_relative 'lib/test_runner'

run Mumukit::TestServerApp
```

And run as `bundle exec rackup`

## Testing

You can unit test any runner developed with mumukit since you are just extending plain ruby classes. 

You can also do integration testing. There are two options: 

* Running a local mumuki-platform instance
* Or using mumukit-bridge, wich is the standalone component that is used by the platform to interact with the runners. Here there is a test template: https://gist.github.com/flbulgarelli/defdc7adbd115481d4bc

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mumuki/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
