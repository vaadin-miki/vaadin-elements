require('test_helper') || require_relative('../test_helper')

class Vaadin::IconTest < Minitest::Test

  include Vaadin::ViewHelpers

  def test_icon
    html = vaadin_icon :check
    assert_equal %{<iron-icon icon="vaadin-icons:check"></iron-icon>}, html
  end

  def test_many_icons
    html = vaadin_icon :check, :arrow_forward
    assert_equal %{<iron-icon icon="vaadin-icons:check"></iron-icon><iron-icon icon="vaadin-icons:arrow-forward"></iron-icon>}, html
  end

end