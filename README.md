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

`require 'vaadin/elements'`

Include helpers (Sinatra):

`helpers Vaadin::ViewHelpers`

Import the elements (erb):

```<head>
     ...
     <%= import_vaadin_elements %>
     ...
   </head>
   <body>
     ...
   </body>
```

### Combo box

`vaadin_combo_box :object, :method, choices, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `item_value_path` and `item_label_path` - specify attribute from the collection that will be used as value and caption of an item, respectively
* `immediate` - either `true` or a path to post data to immediately on value change; default route is REST-like (object/id/method), with POSTed id of the component and value; response should be valid JSON for server callback
* `id` - to overwrite the default id or provide a custom one (required when `immediate`)
* `use_callback` - either `true` or a name of a JavaScript available function to call with the response; when `true`, default `serverCallbackResponse` is used and it expects `application/json` as response type
* `events` - map of `event_name: true_or_path` with handled events; `value-changed` events can be declared this way, too (though `immediate` has a higher precedence and is recommended)

All events are supported.

### Date picker

`vaadin_date_picker :object, :method, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `label` - caption of the component
* `immediate` - either `true` or a path to post data to immediately on value change; default route is REST-like (object/id/method), with POSTed id of the component and value; response should be valid JSON for server callback
* `id` - to overwrite the default id or provide a custom one (required when `immediate`)
* `use_callback` - either `true` or a name of a JavaScript available function to call with the response; when `true`, default `serverCallbackResponse` is used and it expects `application/json` as response type
* `events` - map of `event_name: true_or_path` with handled events; `value-changed` events can be declared this way, too (though `immediate` has a higher precedence and is recommended)

All events are supported.

### Grid

`vaadin_grid :object, :method, choices, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `column_names` - array of strings with names of columns to show (they will be humanised before outputting: "first_name" -> "First Name")
* `id` - to overwrite the default id or provide a custom one

Currently no events are supported from the grid.

## DISCOURAGED: Legacy usage

Please note that this is now a discouraged way of using Vaadin::Elements, as it mixes the logic related to UI components with the main code of the application. However, it gives almost full control over what and how everything will be rendered, and it is possible to listen to non-standard events this way.

Set up elements (this should be an instance variable in the application code):

`@elements = Vaadin::Elements.new`

Set up an element:

`@elements.myComboBox = Vaadin::Elements.combo_box

Or set up properties in the code:

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

### Supported components

* ComboBox - `<vaadin-combo-box>`, `@elements.myComboBox = Vaadin::Elements.combo_box`
* Grid - `<vaadin-grid>`, `@elements.myGrid = Vaadin::Elements.grid`
* DatePicker - `<vaadin-date-picker>`, `@elements.myDatePicker = Vaadin::Elements.date_picker`

The properties of all components can also be created with `Vaadin::Elements.new`. The advantages of using dedicated helpers are:

* the properties that can be set are limited to only those that the corresponding element has
* the `value-changed` event is listened to by default

All events broadcast by these elements can be listened to. By default only `value-changed` is and only when using dedicated helper, and it posts to `/~/:id`. Events can be listened to by using one of the two:

* `element.vaadin_events << 'event-name` for a default path `/~/:id`
* `element.vaadin_events['event-name'] = '/path/with/:id/or/:event` for a custom path

In either case a POST request is made. `:id` and `:event` are replaced with the element's id and the event name, respectively.

## Limitations

There is plenty of limitations at the moment and pretty much anything can change. For things not listed here, file an issue.

Major limitations:

* An object passed to the grid or combo box must have a valid `to_json` implementation.
* Date `value-changed` event sends a `String` when using a helper.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vaadin-miki/vaadin-elements.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

