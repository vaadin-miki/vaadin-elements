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
  # Placeholder for available elements.
  #
  module Elements
    ##
    # Currently supported Vaadin Elements.
    #
    AVAILABLE = %w{vaadin-grid vaadin-combo-box vaadin-date-picker vaadin-icons vaadin-upload}

  end
end