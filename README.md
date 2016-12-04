[![Build Status](https://travis-ci.org/mumuki/mumukit.svg)](https://travis-ci.org/mumuki/mumukit)
[![Code Climate](https://codeclimate.com/github/mumuki/mumukit/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumukit)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumukit/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumukit)

# Mumukit

> Micro framework for quickly implement Mumuki runners

## Installing

You usually add mumukit to an empty project. First you need to add it to your Gemfile:

```
gem 'mumukit'
```

or, if you want latest version:


```
gem 'mumukit', github: 'mumuki/mumukit', branch: 'master'
```

And then `bundle install`

## Ruby Version

`mumukit` works with Ruby 2.0-2.3

## Getting started

### Hooks

`mumukit` is a framework where nearly everything is a _hook_ - a class you must implement following some naming and method conventions.
In order to implement a Mumuki Runner with `mumukit`, you need zero or more of the following:

* `query_hook`: lets runner to run queries like in a native console
* `version_hook`: lets runner to specify a version
* `feedback_hook`: lets runner to generate explanations of compiler/interpreter tools
* `expectations_hook`: lets runner to execute expectations
* `validation_hook`: lets runner to validate request in order to detect malicious code

### Components

In addition, `mumukit` provides some _components_ to make implementation of hooks easier:

* `Mumukit::IsolatedEnvironment`
* `Mumukit::Cookie`
* `Mumukit::Metatest`
* `Mumukit::Explainer`

### Templates

Also, `mumukit` provides _templates_ that implement some specialized use cases hooks:

* `Mumukit::Templates::FileHook`: allows to implement `test_hooks` and `query_hooks` that interact with external command line tools using files and command line arguments
* `Mumukit::Templates::MulangExpectationsHook`: allows to implement `expectation_hooks` that rely on [mulang](https://github.com/mumuki/mulang) tool

## Extensions

Finally, `mumukit` templates provides the following _extensions_ - features that can be activated in some `hooks`:

*  `Mumukit::Templates::FileHook`:
  * `structured`: lets to process JSON output from external commands
  * `mashup`: lets to generate source code files
  * `isolated`: lets to run commands within docker or in native environment
* `Mumukit::Templates::MulangExpectationsHook`
  * `include_smells`: lets to include in the result smells produced by _mulang_