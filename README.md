# Vaadin::Elements

Simple and engine-independent way of using Vaadin Elements from within a Ruby-based web-application.

Currently under development, tested only with Sinatra.

## Installation

Add this line to your application's Gemfile:

```
gem 'vaadin-elements'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vaadin-elements

## Usage

Require elements (Ruby code):

`require 'vaadin/elements'`

Include helpers (Sinatra):

`helpers Vaadin::ViewHelpers`

Import the elements (view):

    <head>
      ...
      <%= import_vaadin_elements %>
      ...
    </head>

Use the elements through helpers `vaadin_element_name_underscored`, e.g.:

    <body>
      ...
      <%= vaadin_combo_box :person, :country, Country.find_all, item_value_path: id, item_label_path: name, immediate: true %>
      ...
    </body>

Helpers are expected to be used mainly in views. Each of the helpers produces a plain string with:

 * corresponding HTML tag with all options that can possibly be set through HTML attributes;
 * if needed - a deferred `script` tag with JS that will be executed once the page is loaded and the element is ready.

Importing the elements can be also done through [Polygit](http://polygit.org/). In that case use `import_through_polygit` instead of `import_vaadin_elements`. Note that this is experimental and may not really work. Any feedback would be more than welcome! 

### Combo box

`vaadin_combo_box :object, :method, choices, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `item_value_path` and `item_label_path` - specify attribute from the collection that will be used as value and caption of an item, respectively
* `immediate` - either `true` or a path to post data to immediately on value change; default route is REST-like (object/id/method), with POSTed id of the component and value; response should be valid JSON for server callback
* `id` - to overwrite the default id or provide a custom one (required when `immediate`)
* `use_callback` - either `true` or a name of a JavaScript available function to call with the response; when `true`, default `serverCallbackResponse` is used and it expects `application/json` as response type
* `events` - map of `event_name: true_or_path` with handled events; `value-changed` events can be declared this way, too (though `immediate` has a higher precedence and is recommended)
* `verbose_event` - either `true` or `false`; when `true`, event data sent to the server will include more details than just the name-value pair 

All events are supported.

### Date picker

`vaadin_date_picker :object, :method, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `label` - caption of the component
* `immediate` - either `true` or a path to post data to immediately on value change; default route is REST-like (object/id/method), with POSTed id of the component and value; response should be valid JSON for server callback
* `id` - to overwrite the default id or provide a custom one (required when `immediate`)
* `use_callback` - either `true` or a name of a JavaScript available function to call with the response; when `true`, default `serverCallbackResponse` is used and it expects `application/json` as response type
* `events` - map of `event_name: true_or_path` with handled events; `value-changed` events can be declared this way, too (though `immediate` has a higher precedence and is recommended)
* `month_names`, `weekdays_short`, `first_day_of_week`, `today`, `cancel` - options to pass to `i18n` of the date picker that contain month names, short weekday names, number of the first day of the week (0 is Sunday), and captions for _Today_ and _Cancel_ buttons, respectively; note that these are set up once the component is ready
* `verbose_event` - either `true` or `false`; when `true`, event data sent to the server will include more details than just the name-value pair 

All events are supported.

### Upload

`vaadin_upload :target, html_options` - parameter `target` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `id` - required when `immediate`
* `immediate` - either `true` or path to post data to immediately on file upload done; no other event is called, even when the upload fails
* `target` - path to post the file to; while not required, it is recommended; can be provided either as an option or as a simple string outside of options map
* `i18n` - map with localised messages, as defined in the [official documentation for i18n](https://vaadin.com/docs/-/part/elements/vaadin-upload/vaadin-upload-i18n.html)
* `events` - map with event names and paths to post data to, as defined in the [official documentation for events](https://vaadin.com/docs/-/part/elements/vaadin-upload/vaadin-upload-basic.html)
* `verbose_event` - either `true` or `false`; when `true`, event data sent to the server will include more details than just the name-value pair 

### Grid

`vaadin_grid :object, :method, choices, html_options` - parameter `method` is optional; optional block can be given - it will be inserted between the element tags

Supported options:

* `immediate` - either `true` or path to post data to immediately when selection changes in the grid; note that the parameter `value` contains *a string with a JSON array* of either *selected indices* or *properties specified by `item_value_path`* 
* `item_value_path` - specifies which property of the selected items to pass to immediate events
* `column_names` - array of strings with names of columns to show (they will be humanised before outputting: "first_name" -> "First Name")
* `id` - to overwrite the default id or provide a custom one
* `selection_mode` - when not specified, it is `:single`, other possible values are `:multi`, `:all` and `:disabled`, as stated in [the documentation for Grid](https://vaadin.com/docs/-/part/elements/vaadin-grid/selection.html)
* `verbose_event` - either `true` or `false`; when `true`, event data sent to the server will include more details than just the name-value pair 

Currently no events other than `selection-changed` are supported from the grid.

## Limitations

There is plenty of limitations at the moment and pretty much anything can change. For things not listed here, file an issue.

Major limitations:

* An object passed to the grid or combo box must have a valid `to_json` implementation.
* Date picker's `value-changed` event sends a `String` when using a helper.
* Grid cannot be replaced with combo-box, as it requires changes to the code that receives the data from the event.

## Development

After cloning the repository, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome through [the GitHub page for this project](https://github.com/vaadin-miki/vaadin-elements).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

