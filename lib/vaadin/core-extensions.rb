class Object
  ##
  # Calls a given block passing given parameter to it and returns that parameter as a result.
  #
  def with_this param, &block
    result = param
    block.call(param, binding)
    result
  end
end

class Symbol
  def +(other)
    (self.to_s+other.to_s).to_sym
  end
end

class Hash
  ##
  # Appends given key with current default value
  #
  def << key
    self[key] = self[key]
  end

  ##
  # Presses the map recursively into a map without nested hashes
  def press(separator = '.')
    result = {}
    needs_more = false
    self.each do |key, value|
      if value.is_a?(Hash) then
        needs_more = true
        value.each do |nested_key, nested_value|
          result[key+separator+nested_key] = nested_value
        end
      else
        result[key] = value
      end
    end
    needs_more ? result.press(separator) : result
  end
end

class String
  ##
  # Converts a string from underscore_notation to camelCase
  def camel_case
    parts = self.split('_')
    parts[0] + parts[1..-1].collect { |part| part[0].upcase+part[1..-1] }.join('')
  end
end