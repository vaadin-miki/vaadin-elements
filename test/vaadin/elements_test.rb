require('test_helper') || require_relative('../test_helper')

class Vaadin::ElementsTest < Minitest::Test
  def test_has_version_number
    refute_nil ::Vaadin::VERSION
  end
end
