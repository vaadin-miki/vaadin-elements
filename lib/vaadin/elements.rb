# Vaadin Elements Ruby Utilities
# written by Miki
# (c) 2016 Vaadin - http://www.vaadin.com - http://github.com/vaadin-miki
# Licensed under Apache 2.0 License

require "vaadin/elements/version"
require 'vaadin/jsonise'
require 'vaadin/core-extensions'

module Vaadin
  # view helpers to generate JS in a view of a sinatra app
  module ViewHelpers
    require_relative 'jsonise'

    # sets up vaadin elements, i.e. binds events and sets their initial values
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
                "#{element}.addEventListener(\"value-changed\", function(e) {ajax.post(\"" +
                (@elements[element].has_key?("onValueChanged") ? @elements[element]["onValueChanged"] : "~/"+element) +
                "\", {id: '#{element}', value: e.detail.value}, serverCallbackResponse)});\n"
          end.join("\n") +
          "});"
    end

    # generates imports for specified elements
    def import_vaadin_elements(*elements)
      elements = Vaadin::Elements::AVAILABLE if elements.empty?
      path_elements = elements + ["components"]
      path_base = "http://polygit2.appspot.com/polymer+v1.3.1/" + path_elements.join("+vaadin+*/")+"/"

      # TODO moment should be imported only if vaadin-date-picker is selected!
      (["<script src=\"#{path_base}webcomponentsjs/webcomponents-lite.min.js\"></script>",
        "<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>"
      ]+elements.collect { |element| "<link href=\"#{path_base}#{element}/#{element}.html\" rel=\"import\">" }).join("\n")
    end
  end


  # basic elements class
  class Elements < Hash
    AVAILABLE = %w{vaadin-grid vaadin-combo-box vaadin-date-picker}

    include HashKeysAsMethods
    include RememberHashChanges

    def sync(params)
      ignore_changes do
        params.keys.select { |k| k != "id" }.each { |key| self[params["id"]][key] = params[key] } if params["id"]
      end
    end

    {"combo_box" => %w{allowCustomValue disabled itemLabelPath items itemValuePath label opened readonly selectedItem value},
     "grid" => %w{cellClassGenerator columns disabled footer frozenColumns header items rowClassGenerator rowDetailsGenerator selection size sortOrder visibleRows},
     "date_picker" => %w{i18n initialPosition label value}
    }.each do |key, value|
      define_singleton_method key do
        result = Elements.new.extend(HashWithLimitedKeys)
        result.allowed_keys = value
        result
      end
    end

  end
end