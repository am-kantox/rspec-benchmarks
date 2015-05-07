# Rspec::Benchmarks

This gem provides benchmarks-on-steroids functionality to rspec. Currently it allows:

* print out summaries on [view, controller, db] access for each rspec example; pitfalls: different rails events show ...hummm... very different times, still trying to configure out wtf (rails developers are definitely anarchists, please refer to _“Anthropology from a Pragmatic Point of View”_ by Immanuel Kant; @john look, Kant is still everywhere, I wonder why we are not called Kant-axe after all.)
* adopted SQL lexer to build AST based on db queries; it was sexy but I still can’t understand what I have this implemented for (possible application: analysis of heavy queries by their structure)
* ability to make examples _fail_ unless they are passed in specified timeslice (relative times are used, no dependence on target machine equipment, times are normalized by precalculated value)
* ability to turn on the full benchmark logging (holy load of statistics.)
* pickup tests to run from git commit;
* highly tunable running config.

## Impression

![RSpec::Benchmarks Screenshot](https://github.com/kantox/kantox-flow/wiki/rspec-benchmarks.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-benchmarks'
```

## Usage

$ BENCHMARK=true bundle exec rspec `bspec last:5`

I know it’s ugly syntax, but it will execute five last specs added (basing on git history.)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-benchmarks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
