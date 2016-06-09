# Vaadin Elements view helpers

module Vaadin

##
# This module contains view helpers that generate JavaScript code.
# Its intended use is with Sinatra.
#
  module ViewHelpers
    require 'vaadin/jsonise'

    def import_elements(path_infix, webcomponents_infix, elements, &path_block)
      elements = Vaadin::Elements::AVAILABLE if elements.empty?
      path_base = path_block.call(elements)

      # there was lastest/ between path_base and webcomponentsjs for cdn (direct) import
      static_imports = ["<script src=\"#{path_base}#{webcomponents_infix}webcomponentsjs/webcomponents-lite.min.js\"></script>",
                        "<script src=\"https://cdn.rawgit.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>"
      ]
      static_imports << "<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>" if elements.include?('vaadin-date-picker')

      (static_imports+elements.collect { |element| "<link href=\"#{path_base}#{path_infix}#{element}/#{element}.html\" rel=\"import\">" }).join("\n")
    end

    ##
    # Generates imports for specified element types. If the specified types are not provided, all supported types will be imported (as defined in Vaadin::Elements::AVAILABLE.)
    #
    # @oaram elements [Array<String>] with element types to import.
    # @return [String] with HTML code.
    def import_vaadin_elements(*elements)
      import_elements("master/", "latest/", elements) { |_| 'https://cdn.vaadin.com/vaadin-core-elements/' }
    end

    ##
    # Generates imports for specified elements through polygit. This will enable using other Polymer elements. If no elements are specified, all of them are imported.
    #
    # @param elements [Array<String>] with elements and polymer components to import.
    # @return [String] with HTML imports.
    def import_through_polygit(*elements)
      import_elements("", "", elements) { |els| 'http://polygit2.appspot.com/polymer+:master/' + ((els+['components']).join('+vaadin+*/'))+'/' }
    end

    def vaadin_element(name, object, method, html_options, block, **options)
      html_options = (object.nil? ? {} : (method.nil? ? {id: object, name: object} : {id: [object, method].join('_'), name: "#{object}[#{method}]", })).merge(html_options)

      # id is required except when the helper is used with no parameters at all
      raise "#{name} must have an id (either implicit or explicit)" unless html_options[:id] || (object.nil? && method.nil? && !html_options[:immediate] && (options[:condition].nil? || options[:condition].call))

      # custom value
      value_attr = html_options[:item_value_path]

      # immediateness
      # by default causes a rest-like post to /object/id/method if there is id, or /object/method if there is no id, or can be specified
      immediate = html_options.delete :immediate

      data = instance_variable_get("@#{object}") rescue nil

      # other events - immediate is a syntax sugar for value-changed
      events = html_options.delete(:events) || {}
      events[options.delete(:immediate_event) || 'value-changed'] = immediate
      events.reject! { |_, value| value.nil? }

      # default callback is disabled by default
      default_callback = html_options.delete(:use_callback) || 'null'
      default_callback = 'serverCallbackResponse' if default_callback === true

      # replace placeholders and construct default event routes
      events.each do |key, value|
        value = if data && data.respond_to?(:id) then
                  "/#{object}/#{data.id}" + (method.nil? ? '' : "/#{method}")
                elsif method.nil? then
                  "/#{object || html_options[:id]}"
                else
                  "/#{object}/#{method}"
                end if value === true
        events[key] = value.gsub(':id', html_options[:id].to_s).gsub(':event', key.to_s.gsub('_', '-'))
      end unless events.empty?

      # get the actual value
      if data then
        data = data.send(method) if method && data.respond_to?(method)
        data = data.send(value_attr) if value_attr
      end

      inline_value = options.delete(:value_as)
      # value may be inlined
      html_options[inline_value] = data if data && inline_value

      # some attributes are converted to js for setup
      js_attributes = {}
      (options[:js_attributes] || {}).each do |jsatt, rubyatts|
        # attributes that are supported as provided
        if rubyatts === true then
          js_attributes[jsatt] = html_options.delete(jsatt) if html_options.has_key?(jsatt)
          js_attributes[jsatt] = js_attributes[jsatt].press('.') if js_attributes[jsatt].is_a?(Hash)
        else
          # attributes that are inlined into helper attributes
          rubyatts = jsatt if rubyatts === true
          rubyatts = [rubyatts] unless rubyatts.is_a?(Array)
          rubyatts = rubyatts.select { |att| html_options.include?(att) }
          jsatt = jsatt.to_s.camel_case
          js_attributes[jsatt] = {} unless rubyatts.empty?
          rubyatts.each { |att| js_attributes[jsatt][att.to_s.camel_case] = html_options.delete(att) }
        end
      end

      options[:event_detail] ||= 'value'
      # default event property to be sent as value
      event_detail = 'detail'
      event_detail += ".#{options[:event_detail]}" if options[:event_detail] && !options[:event_detail].empty?

      # put as attributes
      attributes = html_options.collect { |att, val| "#{att.to_s.gsub('_', '-')}=\"#{val}\"" }.join(' ')

      result = "<vaadin-#{name}"
      result += ' '+attributes unless attributes.empty?
      result += '>'
      result += block.call if block
      result += "</vaadin-#{name}>"

      # build js
      js = []

      # call the extra block
      yield(js, data, events, html_options, default_callback) if block_given?

      js << "cb.value = #{data.to_json};" if data && !inline_value && !options[:value_as_selection]

      # the unless clause in the next line is here because of a missing feature in Grid Element
      # more details available under https://github.com/vaadin/vaadin-grid/issues/201
      # once that issue is fixed, the workaround should no longer be needed
      events.each do |event, route|
        # the parameter may go with extra nesting if foo[bar] is used as a name
        # note this code repeats in the vaadin_grid block
        extra = [
            (($3 ? "#{$1}: {#{$3}: e.#{event_detail}}" : "#{$1}: e.#{event_detail}") if html_options[:name] =~ /(\w+)(\[(\w+)\])?/),
            ("name: '#{html_options[:name]}'" if html_options[:name])
        ].compact.join(", ")
        extra = ", "+extra unless extra.empty?
        # as per #25 the 'name' and the above are extra parameters to help handling automatic updating of the objects
        ajax_post = "ajax.post('#{route}', {id: '#{html_options[:id]}', value: e.#{event_detail}#{extra}}, #{default_callback})"

        js << %{cb.addEventListener('#{event.to_s.gsub('_', '-')}', function(e) {#{ajax_post};});} unless options[:overwritten_default_events] && options[:overwritten_default_events].include?(event)
      end

      # set up all js attributes from the helper
      js_attributes.each do |att, value|
        if value.is_a?(Hash)
          value.each { |meth, param| js << "cb.set(\"#{att}.#{meth.to_s.camel_case}\", #{param.to_json});" }
        elsif value
          js << "cb.#{att} = #{value.to_json}"
        end
      end

      unless js.empty?
        result += "<script async=\"false\" defer=\"true\">"
        result += "document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"##{html_options[:id]}\");"
        result +=js.join('')
        result += '});</script>'
      end
      result
    end

    def vaadin_collection_element(name, object, method, choices, html_options, block, **options, &extra_js)
      # method may be skipped
      method, choices = nil, method if choices.nil? && method
      object, choices = nil, object if choices.nil? && method.nil? && object

      options[:column_names] = html_options.delete(:column_names)
      options[:lazy_load] = html_options.delete(:lazy_load)
      options[:lazy_load], choices = choices, nil if choices.is_a?(String)
      options.delete(:lazy_load) unless options[:lazy_load].is_a?(String)

      vaadin_element(name, object, method, html_options, block, options.merge(condition: ->() { choices.nil? || choices.empty? })) do |js, data, events, html_opts, default_callback|
        if choices && !choices.empty? then
          js << "cb.items = #{choices.to_json};"
          js << "cb.selection.select(#{choices.find_index(data)});" if data && options[:value_as_selection]
        end
        js << "cb.columns = #{options[:column_names].collect { |n| {name: n} }.to_json};" if options[:column_names]
        js << "cb.items = function(params, callback) {ajax.post(\"#{options[:lazy_load]}\", params, function(e) {var json = JSON.parse(e);callback(json.result, json.size);});};" if options[:lazy_load]

        extra_js.call(js, data, events, html_opts, default_callback) if extra_js
      end
    end

    ##
    # Renders HTML of a vaadin combo box.
    # Uses JS to load the real data.
    def vaadin_combo_box(object = nil, method = nil, choices = nil, **html_options, &block)
      vaadin_collection_element('combo-box', object, method, choices, html_options, block)
    end

    def vaadin_date_picker(object = nil, method = nil, **html_options, &block)
      vaadin_element('date-picker', object, method, html_options, block, value_as: 'value', js_attributes: {i18n: %i{month_names weekdays_short first_day_of_week today cancel}})
    end

    def vaadin_grid(object = nil, method = nil, choices = nil, **html_options, &block)
      item_value_path = html_options.delete(:item_value_path)
      item_value_path = item_value_path ? "item.#{item_value_path}" : 'index'

      vaadin_collection_element('grid', object, method, choices, html_options, block, value_as_selection: true, immediate_event: 'selected-items-changed', overwritten_default_events: 'selected-items-changed') do |js, data, events, html_opts, default_callback|
        # the parameter may go with extra nesting if foo[bar] is used as a name
        extra = [
            (($3 ? "#{$1}: JSON.stringify({#{$3}: JSON.stringify(selection)})" : "#{$1}: JSON.stringify(selection)") if html_opts[:name] =~ /(\w+)(\[(\w+)\])?/),
            ("name: '#{html_opts[:name]}'" if html_opts[:name])
        ].compact.join(", ")
        extra = ", "+extra unless extra.empty?

        js << %{cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector("##{html_opts[:id]}").selection.selected(function(index){var grItem;document.querySelector("##{html_opts[:id]}").getItem(index, function(err, item){grItem=#{item_value_path};});return grItem;});ajax.post('#{events['selected-items-changed']}', {id: '#{html_options[:id]}', value: JSON.stringify(selection)#{extra}}, #{default_callback});});} if events['selected-items-changed']
      end
    end

    def icon icon_set, key = nil
      icon_set, key = 'vaadin-icons', icon_set unless key
      "<iron-icon icon=\"#{icon_set.to_s.gsub("_", "-")}:#{key.to_s.gsub("_", "-")}\"></iron-icon>"
    end

    def vaadin_icon *keys
      keys.collect { |key| icon :vaadin_icons, key }.join
    end

    def vaadin_upload(target = nil, **html_options, &block)
      html_options[:target] = target unless html_options.include?(:target) || target.nil?
      vaadin_element('upload', nil, nil, html_options, block, immediate_event: 'upload-success', event_detail: '', js_attributes: {i18n: true})
    end

  end

end