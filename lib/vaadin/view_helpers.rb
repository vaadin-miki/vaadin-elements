# Vaadin Elements view helpers

module Vaadin

##
# This module contains view helpers that generate JavaScript code.
# Its intended use is with Sinatra.
#
  module ViewHelpers
    require 'vaadin/jsonise'

    ##
    # Sets up Vaadin Elements, i.e. binds events and sets their initial values.
    # Accepts an array of ids of elements to be bound. If that array is not present or empty, all elements in +@elements+ are used.
    #
    # @param elements [Array<String>] with ids of elements to be bound.
    # @return [String] with JS code.
    def setup_vaadin_elements(*elements)
      elements = (@elements || {}).keys if elements.empty?
          "document.addEventListener(\"WebComponentsReady\", function (e) {\n" +
          elements.collect do |element|
            "var #{element} = document.querySelector(\"##{element}\");\n" +
                @elements[element].collect { |key, value| "if('#{key}' in #{element}) {\n#{element}.#{key} = #{value.to_json}\n};" }.join("\n") + "\n" +
                @elements[element].vaadin_events.collect do |event, post|
                  "#{element}.addEventListener(\"#{event}\", function(e) {ajax.post(\"" +
                      (post || '~/:id').gsub(':id', element).gsub(':event', event) +
                      "\", {id: '#{element}', value: e.detail.value}, serverCallbackResponse)});\n"
                end.join("\n")
          end.join("\n") +
          '});'
    end

    ##
    # Generates imports for specified element types. If the specified types are not provided, all supported types will be imported (as defined in Vaadin::Elements::AVAILABLE.)
    #
    # @oaram elements [Array<String>] with element types to import.
    # @return [String] with JS code.
    def import_vaadin_elements(*elements)
      elements = Vaadin::Elements::AVAILABLE if elements.empty?
      path_elements = elements + ['components']
      path_base = 'http://polygit2.appspot.com/polymer+v1.3.1/' + path_elements.join('+vaadin+*/')+'/'

      # TODO moment should be imported only if vaadin-date-picker is selected!
      (["<script src=\"#{path_base}webcomponentsjs/webcomponents-lite.min.js\"></script>",
        "<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>",
        "<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>"
      ]+elements.collect { |element| "<link href=\"#{path_base}#{element}/#{element}.html\" rel=\"import\">" }).join("\n")
    end

    def vaadin_element(name, object, method, html_options, block, **options)
      html_options = (object.nil? ? {} : (method.nil? ? {id: object, name: object} : {id: [object, method].join("_"), name: "#{object}[#{method}]", })).merge(html_options)

      # id is required except when the helper is used with no parameters at all
      raise "#{name} must have an id (either implicit or explicit)" unless html_options[:id] || (object.nil? && method.nil? && !html_options[:immediate] && (options[:condition].nil? || options[:condition].call))

      # custom value
      value_attr = html_options[:item_value_path]

      # immediateness
      # by default causes a rest-like post to /object/id/method if there is id, or /object/method if there is no id, or can be specified
      immediate = html_options.delete :immediate

      data = instance_variable_get("@#{object}") rescue nil
      immediate = if data && data.respond_to?(:id) then
                    "/#{object}/#{data.id}" + (method.nil? ? "" : "/#{method}")
                  elsif method.nil? then
                    "/#{object || html_options[:id]}"
                  else
                    "/#{object}/#{method}"
                  end if immediate === true

      # get the actual value
      if data then
        data = data.send(method) if method && data.respond_to?(method)
        data = data.send(value_attr) if value_attr
      end

      # default callback is disabled by default
      default_callback = html_options.delete(:use_callback) || 'null'
      default_callback = 'serverCallbackResponse' if default_callback === true

      # replace placeholders
      if immediate then
        options[:immediate_event] ||= 'value-changed'
        immediate = immediate.gsub(':id', html_options[:id].to_s).gsub(':event', options[:immediate_event])
      end

      inline_value = options.delete(:value_as)
      # value may be inlined
      html_options[inline_value] = data if data && inline_value

      attributes = html_options.collect { |att, val| "#{att.to_s.gsub("_", "-")}=\"#{val}\"" }.join(" ")

      result = "<vaadin-#{name}"
      result += " "+attributes unless attributes.empty?
      result += ">"
      result += block.call if block
      result += "</vaadin-#{name}>"

      # build js
      js = []
      yield(js, data) if block_given?
      js << "cb.value = #{data.to_json};" if data && !inline_value && !options[:value_as_selection]
      js << %{cb.addEventListener('#{options[:immediate_event]}', function(e) {ajax.post('#{immediate}', {id: '#{html_options[:id]}', value: e.detail.value}, #{default_callback});});} if immediate

      unless js.empty?
        result += "<script async=\"false\" defer=\"true\">"
        result += "document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"##{html_options[:id]}\");"
        result +=js.join("")
        result += "});</script>"
      end
      result
    end

    def vaadin_collection_element(name, object, method, choices, html_options, block, **options, &extra_js)
      # method may be skipped
      method, choices = nil, method if choices.nil? && method
      object, choices = nil, object if choices.nil? && method.nil? && object

      options[:column_names] = html_options.delete(:column_names)

      vaadin_element(name, object, method, html_options, block, options.merge(condition: ->() { choices.nil? || choices.empty? })) do |js, data|
        if choices && !choices.empty? then
          js << "cb.items = #{choices.to_json};"
          js << "cb.selection.select(#{choices.find_index { |e| e == data }});" if data && options[:value_as_selection]
          js << "cb.columns = #{options[:column_names].collect { |name| {name: name} }.to_json};" if options[:column_names]
        end

        extra_js.call(js, data) if extra_js
      end
    end

    ##
    # Renders HTML of a vaadin combo box.
    # Uses JS to load the real data.
    def vaadin_combo_box(object = nil, method = nil, choices = nil, **html_options, &block)
      vaadin_collection_element("combo-box", object, method, choices, html_options, block)
    end

    def vaadin_date_picker(object = nil, method = nil, **html_options, &block)
      vaadin_element('date-picker', object, method, html_options, block, value_as: 'value')
    end

    def vaadin_grid(object = nil, method = nil, choices = nil, **html_options, &block)
      vaadin_collection_element("grid", object, method, choices, html_options, block, value_as_selection: true, immediate_event: 'selected-items-changed')
    end

  end

end