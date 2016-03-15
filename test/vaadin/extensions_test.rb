require 'test_helper'

class Vaadin::ExtensionsTest < Minitest::Test

  class MockHash < Hash
    include HashKeysAsMethods
    include RememberHashChanges
    include HashWithLimitedKeys
  end

# Called before every test method runs. Can be used
# to set up fixture information.
  def setup
    @map = MockHash.new
  end

# Called after every test method runs. Can be used to tear
# down fixture information.

  def teardown
    # Do nothing
  end

  def test_assign
    @map.foo = "bar"
    assert_equal "bar", @map.foo
  end

  def test_nested_assign
    @map.foo.bar = "hello!"
    assert_equal "hello!", @map.foo.bar
    assert_equal({"bar" => "hello!"}, @map.foo)
  end

  def test_changed_attributes
    @map.foo = "bar"
    @map.bar.baz = "hello"
    @map.bar.gee = "ohai"
    assert_equal ["foo", "bar"], @map.changed_attributes
  end

  def test_changes_map
    @map.foo = "bar"
    @map.bar.baz = "hello"
    @map.bar.gee = "ohai"
    assert_equal({"foo" => "bar", "bar" => {"baz" => "hello", "gee" => "ohai"}}.to_a, @map.changes_map.to_a)
  end

  def test_modified_changes_map
    @map.ignore_changes = true
    @map.foo = "bar"
    @map.stare = "old"
    @map.bar.baz = "hello"
    @map.bar.gee = "ohai"
    @map.ignore_changes = false
    @map.foo = "BAR!"
    @map.nowe = "this new"
    @map.bar.gee = "NO WAI"

    assert_equal({"foo" => "BAR!", "nowe" => "this new", "bar" => {"gee" => "NO WAI"}}.to_a, @map.changes_map.to_a)
  end

  def test_nested_changes_map
    @map.this.is.sparta = "ohai"
    @map.ignore_changes = true
    @map.this.is.not = "sparta"
    assert @map.has_changes?
  end

  def test_ignore_changes_block
    @map.ignore_changes { @map.foo = "bar" }
    refute @map.has_changes?
    assert !@map.ignore_changes
  end

  def test_limited_keys
    @map.allowed_keys = %w{foo bar baz}
    @map.foo = "foo"
    @map.blah = "nope"
    @map["bar"] = "bar"
    assert_equal(2, @map.keys.size)
    assert_equal("foo", @map.foo)
    assert_equal("bar", @map.bar)
    assert_equal([["foo", "foo"], ["bar", "bar"]], @map.to_a)
  end

  def test_clear_disallowed_keys
    @map.foo = "foo"
    @map.blah = "nope"
    @map["bar"] = "bar"

    @map.allowed_keys = %w{foo bar baz}
    # nothing happens
    assert_equal({"foo" => "foo", "blah" => "nope", "bar" => "bar"}, @map)

    @map.clear_disallowed_keys!

    assert_equal(2, @map.keys.size)
    assert_equal("foo", @map.foo)
    assert_equal("bar", @map.bar)
    assert_equal([["foo", "foo"], ["bar", "bar"]], @map.to_a)
  end

  def test_clearing_changes
    @map.foo = "bar"
    @map.bar = "foo"
    changed = @map.clear_changes { @map.changed_attributes }
    assert_equal(%w{foo bar}, changed)
    assert_empty @map.changed_attributes
  end

  def test_clear_changes_on_clear
    @map.foo = "bar"
    @map.bar = "foo"
    assert_equal %w{foo bar}, @map.changed_attributes
    @map.clear
    assert_empty @map.changed_attributes
  end
end