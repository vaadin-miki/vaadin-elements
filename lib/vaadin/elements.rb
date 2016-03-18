# Vaadin Elements Ruby Utilities
# written by Miki
# (c) 2016 Vaadin - http://www.vaadin.com - http://github.com/vaadin-miki/vaadin-elements

require 'vaadin/elements/version'
require 'vaadin/jsonise'
require 'vaadin/core-extensions'
require 'date'

##
# Top level module for all Vaadin-related and -branded code.
#
module Vaadin
  ##
  # This module contains view helpers that generate JavaScript code.
  # Its intended use is with Sinatra.
  #
  module ViewHelpers
    require_relative 'jsonise'

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
  end

  ##
  # Basic elements class. This should be an instance variable accessible easily by the controller and the view. By convention, its name should be +@elements+.
  #
  class Elements < Hash
    ##
    # Currently supported Vaadin Elements.
    #
    AVAILABLE = %w{vaadin-grid vaadin-combo-box vaadin-date-picker}

    include HashKeysAsMethods
    include RememberHashChanges
    include HashWithLimitedKeys
    include HashValueModification

    attr_accessor :vaadin_element, :vaadin_events

    def initialize
      @vaadin_events = Hash.new
    end

    ##
    # Synchronises the state of the Elements stored in this object with whatever is in the parameters.
    #
    # @param params [Hash] with parameter from a request.
    def sync(params)
      ignore_changes do
        params.keys.select { |k| k != 'id' }.each { |key| self[params['id']][key] = params[key] } if params['id']
      end
    end

    #
    # these are predefined methods with allowed keys limited to public API of each corresponding element
    #
    {'combo_box' =>
         {properties: %w{allowCustomValue disabled itemLabelPath items itemValuePath label opened readonly selectedItem value},
          events: %w{value-changed}
         },
     'grid' =>
         {properties: %w{cellClassGenerator columns disabled footer frozenColumns header items rowClassGenerator rowDetailsGenerator selection size sortOrder visibleRows},
          events: %w{value-changed}
         },
     'date_picker' =>
         {properties: ['initialPosition', 'label', 'value', 'i18n' => %w{monthNames weekdaysShort firstDayOfWeek today cancel formatDate}],
          events: %w{value-changed},
          modifiers: {'value' => [Date.method(:parse)]}
         }
    }.each do |key, value|
      define_singleton_method key do
        result = Elements.new
        result.vaadin_element = key
        result.allowed_keys = value[:properties]
        value[:events].each { |event| result.vaadin_events << event } if value[:events]
        value[:modifiers].each { |attribute, modifiers| result.class.modify_attribute(attribute, *modifiers) } if value[:modifiers]
        result
      end
    end

  end
end