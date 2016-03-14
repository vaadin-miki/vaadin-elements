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

## Supported components

* ComboBox - `<vaadin-combo-box>`, `@elements.myComboBox = Vaadin::Elements.combo_box`
* Grid - `<vaadin-grid>`, `@elements.myGrid = Vaadin::Elements.grid`
* (partially) DatePicker - `<vaadin-date-picker>`, `@elements.myDatePicker = Vaadin::Elements.date_picker`

The properties of all components can also be created with `Vaadin::Elements.new`. The only difference is that the helper methods limit the properties that can be set to only those that the corresponding element has.

## Limitations

There is plenty of limitations at the moment and pretty much everything can change. For those not listed, file an issue.

Major limitations:
* An object passed to the grid or combo box must have a valid `to_json` implementation.
* Events broadcast by the components - other than `value-change` - cannot be listened to.
* DatePicker currently operates on Strings rather than dates.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vaadin-miki/vaadin-elements.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

