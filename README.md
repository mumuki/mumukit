# Mumukit

Gem for quickly implement mumuki runners

## Usage

1. Create a new ruby project: 
    1. create an empty directory
    2. add an empty Gemfile - you can use bundle init
    3. add a Rakefile if you want - usefull for running tests
    4. and a .ruby-version, so that tools like rvm or rbenv know the version of ruby
2. Add mumukit as dependency in the Gemfile: `gem 'mumukit'`
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


## Contributing

1. Fork it ( https://github.com/[my-github-username]/mumuki/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
