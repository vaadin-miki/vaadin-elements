# Vaadin::Elements

Simple and engine-independent way of using Vaadin Elements from within a Ruby-based web-application.

Currently under heavy development and dependent on Sinatra and Erb.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vaadin-elements'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vaadin-elements

## Usage

Require elements:

`require 'vaadin-elements'`

Include helpers (Sinatra):

`include Vaadin::ViewHelpers`

Set up elements:

`@elements = Vaadin::Elements.new`

Set up properties in the code:

`@elements.myComboBox.items = %w{hello elements from Ruby application}`

Setup the view (erb example):

```<head>
     ...
     <%= import_vaadin_elements %>
     ...
   </head>
   <body>
     ...
     <vaadin-combo-box id="myComboBox"></vaadin-combo-box>
     ...
     <script>
       <%= setup_vaadin_elements %>
     </script>
   </body>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vaadin-miki/vaadin-elements.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

