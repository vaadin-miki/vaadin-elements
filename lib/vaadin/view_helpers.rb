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
      elements = @elements.keys if elements.empty?
      "function serverCallbackResponse(e) {\n
         console.log(e);\n
         var resp = JSON.parse(e);\n
         for(var oid in resp) {\n
           var comp = document.querySelector('#'+oid);\n
           for(var meth in resp[oid]) {\n
             if(meth in comp) {\n
             comp[meth] = resp[oid][meth];\n
       }}}};\n" +
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
        "<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>"
      ]+elements.collect { |element| "<link href=\"#{path_base}#{element}/#{element}.html\" rel=\"import\">" }).join("\n")
    end

    ##
    # Renders HTML of a vaadin combo box.
    def vaadin_combo_box(parameters = {})
      result = "<vaadin-combo-box>"
      result += yield if block_given?
      result += "</vaadin-combo-box>"
    end

  end

end