# MiniYaml

MiniYaml is a toolkit for amending and formatting YAML files.

You can use it to:

- Enforce predictable and opinionated formatting for all YAML files
- Amend YAML files programatically while maintaining comments

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_yaml'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mini_yaml

## Usage


To lint an indevidual file use:

```ruby
lint-yaml FILENAME
```

To amend an existing YAML file use:

```ruby
yaml = <<~YAML
  # comment
  - "a"
  - b
YAML

linter = MiniYaml::Linter.new(yaml)
linter.contents << "c"

puts linter.dump

```

This will output:

```
---
# comment
- a
- b
- c
```

## Why not use prettier or some other tool?

mini_yaml is deliberately opinionated. It enforces line length, chooses quoting styles and maintains comments.

Prettier unfortunately is not as opinionated, it will not enforce quoting styles, line length and styles for multiple line strings and so on. This means that you can not rely on it to force consistent styling of YAML in your project.

## Why not use mini-yaml?

MiniYaml is extremely experimental, it includes a "paranoid" mode by default which makes it impossible that it will corrupt YAML, that said, it certainly may have bugs and may fail to handle all sorts of YAML files.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SamSaffron/mini_yaml. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/SamSaffron/mini_yaml/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MiniYaml project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/SamSaffron/mini_yaml/blob/main/CODE_OF_CONDUCT.md).
