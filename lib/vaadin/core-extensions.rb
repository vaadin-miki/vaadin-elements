##
# The module captures +method_missing+ to allow referencing to +[]+ string keys as method names and ensures that newly referenced elements are instances of the same class. In addition, it provides querying helper for each key (+my_key?+).
#
# For example:
#
#     class MyHash < Hash
#       include HashKeysAsMethods
#     end
#
#     wow = MyHash.new
#     wow.this.is = 'amazing!'
#
#     wow.this.is
#     >> 'amazing!'
#
#     wow.this
#     >> {'is' => 'amazing!'}
#
#     wow
#     >> {'this' => {'is' => 'amazing!'}}
#
#     wow.this?
#     >> true
#
#     wow.that?
#     >> false
#
# The drawback is that now each misspelt key will make a new entry in the hash, which might not be what is desired.
# Of course, this only applies to methods that are unknown. No method gets overwritten.
#
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


##
# This module restricts the keys that can be used in +[]+ and +[]=+. Additionally, when +allowed_keys+ is not specified (i.e. is +nil+), then there is no limitation on allowed keys.
#
module HashWithLimitedKeys
  attr_reader :allowed_keys

  ##
  # Clears all attributes that have an invalid key.
  #
  def clear_disallowed_keys!
    self.delete_if { |key, value| !allowed_keys.include?(key) } if allowed_keys
  end

  def allowed_keys=(allowed)
    @allowed_keys = Hash.new
    allowed.each { |key| key.is_a?(Hash) ? @allowed_keys.merge!(key) : @allowed_keys[key] = nil }
  end

  # both []= and [] have a side effect of limiting the value if it happens to limit keys as well
  ["[]=(name, value)", "[](name)"].each { |sig| class_eval(<<METH) }
  def #{sig}
    with_this(super) {|result| result.allowed_keys = allowed_keys[name] if result && result.is_a?(HashWithLimitedKeys) && allowed_keys && allowed_keys[name]}  if allowed_keys.nil? || allowed_keys.include?(name)
  end
METH
end

##
# This module tracks which keys were modified through +[]=+. It also allows an option to stop remembering changes for a while.
#
# This is recursive on the value level, so if a value of a key includes this module, it will be queried for changes.
#
module RememberHashChanges
  require 'set'

  def [](name)
    with_this(super) { |value| value.ignore_changes = @ignore_changes if value.is_a?(RememberHashChanges) }
  end

  def []=(name, value)
    with_this(super) { |value| ((@changes ||= Set.new) << name) unless ignore_changes }
  end

  ##
  # Sets whether or not to ignore changes. When changes are ignored, then any call to +[]=+ will not be remembered.
  #
  def ignore_changes=(yes_no)
    @ignore_changes = yes_no
    values.each { |value| value.ignore_changes = yes_no if value.is_a?(RememberHashChanges) }
  end

  ##
  # Checks if changes are ignored, or optionally (if block given) ignores changes for the execution of the block.
  # call-seq:
  #   ignore_changes => true / false
  #   ignore_changes {block} => result of block
  #
  def ignore_changes
    if block_given? then
      old_ignore = @ignore_changes
      self.ignore_changes = true
      with_this(yield) { |result| self.ignore_changes = old_ignore }
    else
      @ignore_changes
    end
  end

  ##
  # Clears the remembered changes so far. Optionally accepts a block, which means the changes will be cleared after its execution.
  #
  # call-seq:
  #   clear_changes => nil
  #   clear_changes {block} => result of block
  #
  def clear_changes
    result = block_given? ? yield : nil
    if @changes then
      @changes.each { |att| self[att].clear_changes if self[att].is_a?(RememberHashChanges) }
      @changes.clear
    end
    result
  end

  def clear
    clear_changes
    super
  end

  ##
  # Checks whether there were any changes to this object since last time changes were cleared.
  #
  def has_changes?
    (!@changes.nil? && !@changes.empty?) || values.select { |value| value.is_a?(RememberHashChanges) }.any? { |v| v.has_changes? }
  end

  ##
  # Returns a list of changed attributes.
  #
  def changed_attributes
    @changes.to_a
  end

  ##
  # Returns a map of changed attributes and their current values.
  #
  def changes_map
    return self.class.new unless has_changes?
    with_this(@changes ? clear_changes { self.class[@changes.collect { |k| [k, (value = self[k]).is_a?(RememberHashChanges) ? value.changes_map : value] }] } : self.class.new) do |result|
      self.each { |key, value| result[key] = value.changes_map if value.is_a?(RememberHashChanges) && value.has_changes? }
    end
  end
end

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

class Hash
  ##
  # Appends given key with current default value
  #
  def << key
    self[key] = self[key]
  end
end