require('test_helper') || require_relative('../test_helper')

class Vaadin::ElementsTest < Minitest::Test
  def test_has_version_number
    refute_nil ::Vaadin::VERSION
  end

  class AppMock
    include Vaadin::ViewHelpers
    attr_accessor :elements

    def initialize
      @elements = Vaadin::Elements.new
    end
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @app = AppMock.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_combo_box
    combo = Vaadin::Elements.combo_box
    combo.thisNot = "oh no"
    assert_nil(combo.thisNot)
    combo.readonly = true
    json = combo.to_json
    assert_equal("{\"readonly\":true}", json)
    assert_equal("combo_box", combo.vaadin_element)
  end

  def test_date_picker_api
    picker = Vaadin::Elements.date_picker
    picker.i18n.month_names = "this does not work!"
    picker.i18n.monthNames = %w{styczeń luty marzec kwiecień maj czerwiec lipiec sierpień wrzesień październik listopad grudzień}
    assert_nil picker.i18n.month_names
    assert_equal %w{styczeń luty marzec kwiecień maj czerwiec lipiec sierpień wrzesień październik listopad grudzień}, picker.i18n.monthNames
    picker.label = "this will work"
    picker.property ="this will not"
    assert_nil picker.property
    assert_equal "this will work", picker.label
    assert_equal "date_picker", picker.vaadin_element
  end

  def test_date_picker_date
    picker = Vaadin::Elements.date_picker
    picker.value = '2008-08-30'
    assert_equal Date.parse('2008-08-30'), picker.value
  end
end
