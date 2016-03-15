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
  attr_accessor :allowed_keys

  ##
  # Clears all attributes that have an invalid key.
  #
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

##
# This module tracks which keys were modified through +[]=+. It also allows an option to stop remembering changes for a while.
#
# This is recursive on the value level, so if a value of a key includes this module, it will be queried for changes.
#
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
      result = yield
      self.ignore_changes = old_ignore
      result
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
    result = @changes ? clear_changes { self.class[@changes.collect { |k| [k, (value = self[k]).is_a?(RememberHashChanges) ? value.changes_map : value] }] } : self.class.new
    self.each { |key, value| result[key] = value.changes_map if value.is_a?(RememberHashChanges) && value.has_changes? }
    result
  end
end
