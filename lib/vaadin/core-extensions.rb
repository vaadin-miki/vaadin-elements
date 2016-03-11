# modules with extensions to core classes

# extends hash to allow adding keys by typing them as methods
module HashKeysAsMethods
  def [](name)
    super || (self[name] = self.class.new)
  end

  def method_missing(name, *params, &block)
    name = name.to_s
    params = params.first if params.size == 1

    # call block or use params if provided, and is assigning
    return self[name[0..-2]] = ((block && block.call(binding)) || params) if name.to_s.end_with?("=")
    # boolean check if ends with ?
    return !self[name[0..-2]].nil? if name.to_s.end_with?("?")
    # return value otherwise
    self[name]
  end
end

module HashWithLimitedKeys
  attr_accessor :allowed_keys

  def clear_disallowed_keys!
    self.delete_if { |key, value| !allowed_keys.include?(key) } if allowed_keys
  end

  def []=(name, value)
    super if allowed_keys.nil? || allowed_keys.include?(name)
  end

  def [](name)
    super if allowed_keys.nil? || allowed_keys.include?(name)
  end
end

# tracks changes in the object
module RememberHashChanges
  require 'set'

  def [](name)
    value = super
    value.ignore_changes = @ignore_changes if value.is_a?(RememberHashChanges)
    value
  end

  def []=(name, value)
    result = super
    ((@changes ||= Set.new) << name) unless ignore_changes
    result
  end

  def ignore_changes=(yes_no)
    @ignore_changes = yes_no
    values.each { |value| value.ignore_changes = yes_no if value.is_a?(RememberHashChanges) }
  end

  def ignore_changes
    if block_given? then
      old_ignore = @ignore_changes
      self.ignore_changes = true
      result = yield
      self.ignore_changes = old_ignore
      result
    else
      @ignore_changes
    end
  end

  def clear_changes
    result = block_given? ? yield : nil
    if @changes then
      @changes.each { |att| self[att].clear_changes if self[att].is_a?(RememberHashChanges) }
      @changes.clear
    end
    result
  end

  def has_changes?
    (!@changes.nil? && !@changes.empty?) || values.select { |value| value.is_a?(RememberHashChanges) }.any? { |v| v.has_changes? }
  end

  def changed_attributes
    clear_changes { @changes.to_a }
  end

  def changes_map
    return self.class.new unless has_changes?
    result = @changes ? clear_changes { self.class[@changes.collect { |k| [k, (value = self[k]).is_a?(RememberHashChanges) ? value.changes_map : value] }] } : self.class.new
    self.each { |key, value| result[key] = value.changes_map if value.is_a?(RememberHashChanges) && value.has_changes? }
    result
  end
end
