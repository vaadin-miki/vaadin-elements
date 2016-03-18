# Vaadin Elements Ruby Utilities
# written by Miki
# (c) 2016 Vaadin - http://www.vaadin.com - http://github.com/vaadin-miki/vaadin-elements

require 'vaadin/elements/version'
require 'vaadin/core-extensions'
require 'vaadin/view_helpers'
require 'date'

##
# Top level module for all Vaadin-related and -branded code.
#
module Vaadin

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