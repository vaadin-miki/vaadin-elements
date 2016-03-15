require 'json'

##
# JSON helper to include virtual attributes from an object. The result JSON is always a map.
#
# Virtual attributes can be specified using +json_virtual_attributes+ in a following manner:
#
#    class MyClass
#      attr_accessor :att1, :att2
#      json_virtual_attribute :virtual1, :virtual2
#      ...
#      def virtual1
#        ...value of virtual1...
#      end
#
#      def virtual2
#        ...value of virtual2...
#      end
#
# When calling +fron_json+ on an object that includes this module, virtual attributes are ignored.
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
    JSON.load(source).each { |var, val| self.instance_variable_set("@#{var}", val) unless self.class.json_virtual_attributes.include?(var) }
    self
  end
end

