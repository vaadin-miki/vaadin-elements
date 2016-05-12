require('test_helper') || require_relative('../test_helper')
require 'date'

class Vaadin::ExtensionsTest < Minitest::Test

  def test_with_this
    result = with_this(Hash.new) { |x| x['hi'] = 'hello hello' }
    assert_equal(['hi'], result.keys)
    assert_equal({'hi' => 'hello hello'}, result)
  end

  def test_hash_append
    map = Hash.new('default')
    map << 'key'
    assert map.include?('key')
    assert map.is_a?(Hash)
    assert_equal('default', map['key'])
  end

  def test_camel_case
    assert_equal 'thisIsCamelCase', 'this_is_camel_case'.camel_case
  end

  def test_hash_press
    map = {this: 'thing', nested: {level: 'hello', hi: 'there'}, another: {nested: {deep: 'level'}}}
    result = map.press
    assert_equal({this: 'thing', :'nested.level' => 'hello', :'nested.hi' => 'there', :'another.nested.deep' => 'level'}, result)
  end

end