# Galette

Dependency resolution algorithm in ruby.

It could be an alternative to [Bundler](https://github.com/bundler/bundler) and CocoaPods's [Molinillo](https://github.com/CocoaPods/Molinillo) algorithm. It's currently just an experiment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'galette'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install galette

## Usage

```
> availability = Galette::Rubygems.specs_from_requirements({'rails' => '~> 5.1.0'})
> Galette::Resolution.new(availability).resolve
[#<Galette::Version rails =5.1.5>,
 #<Galette::Version actionmailer =5.1.5>,
 #<Galette::Version actionpack =5.1.5>,
 #<Galette::Version activerecord =5.1.5>,
 #<Galette::Version activesupport =5.1.5>,
 #<Galette::Version rake =12.3.0>,
 #<Galette::Version bundler =1.16.1>,
 #<Galette::Version railties =5.1.5>,
 #<Galette::Version sprockets-rails =3.2.1>,
 #<Galette::Version actionview =5.1.5>,
 #<Galette::Version activemodel =5.1.5>,
 #<Galette::Version activejob =5.1.5>,
 #<Galette::Version actioncable =5.1.5>,
 #<Galette::Version mail =2.7.0>,
 #<Galette::Version rails-dom-testing =2.0.3>,
 #<Galette::Version rack =2.0.4>,
 #<Galette::Version rack-test =0.8.2>,
 #<Galette::Version builder =3.2.3>,
 #<Galette::Version i18n =0.9.5>,
 #<Galette::Version tzinfo =1.2.5>,
 #<Galette::Version sprockets =4.0.0.beta6>,
 #<Galette::Version rails-html-sanitizer =1.0.3>,
 #<Galette::Version arel =8.0.0>,
 #<Galette::Version minitest =5.11.3>,
 #<Galette::Version thread_safe =0.3.6>,
 #<Galette::Version concurrent-ruby =1.0.5>,
 #<Galette::Version method_source =0.9.0>,
 #<Galette::Version thor =0.20.0>,
 #<Galette::Version erubi =1.7.0>,
 #<Galette::Version globalid =0.4.1>,
 #<Galette::Version websocket-driver =0.6.5>,
 #<Galette::Version nio4r =2.2.0>,
 #<Galette::Version mini_mime =1.0.0>,
 #<Galette::Version nokogiri =1.8.2>,
 #<Galette::Version loofah =2.2.0>,
 #<Galette::Version websocket-extensions =0.1.3>,
 #<Galette::Version mini_portile2 =2.3.0>,
 #<Galette::Version crass =1.0.3>]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhawthorn/galette. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

