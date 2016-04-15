require('test_helper') || require_relative('../test_helper')

class Vaadin::UploadTest < Minitest::Test

  include Vaadin::ViewHelpers

  def test_empty
    html = vaadin_upload
    assert_equal %{<vaadin-upload></vaadin-upload>}, html
  end

  def test_target_default
    html = vaadin_upload '/upload'
    assert_equal %{<vaadin-upload target="/upload"></vaadin-upload>}, html
  end

  def test_target_attribute
    html = vaadin_upload target: '/upload'
    assert_equal %{<vaadin-upload target="/upload"></vaadin-upload>}, html
  end

end