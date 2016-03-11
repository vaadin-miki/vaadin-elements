require 'json'

# json helper
module Jsonise
  module ClassMethods
    def json_virtual_attributes(*atts)
      atts.empty? ? @json_virtual_attributes || [] : @json_virtual_attributes = atts
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def to_json(*params)
    Hash[(instance_variables.collect { |var| [var[1..-1], instance_variable_get(var)] } +
        self.class.json_virtual_attributes.collect { |var| [var.to_s, self.send(var)] })
             .sort { |x1, x2| x1[0] <=> x2[0] }].to_json(*params)
  end

  def from_json source
    JSON.load(source).each { |var, val| self.instance_variable_set("@#{var}", val) }
    self
  end
end

