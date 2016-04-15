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

  def test_immediate_notification
    html = vaadin_upload target: '/upload', id: 'upload', immediate: '/uploaded'
    assert_equal "<vaadin-upload target=\"/upload\" id=\"upload\"></vaadin-upload><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#upload\");cb.addEventListener('upload-success', function(e) {ajax.post('/uploaded', {id: 'upload', value: e.detail}, null);});});</script>", html
  end

  def test_immediate_progress_callback
    html = vaadin_upload target: '/upload', id: 'upload', events: {upload_success: '/uploaded', upload_progress: '/uploading'}
    assert_equal "<vaadin-upload target=\"/upload\" id=\"upload\"></vaadin-upload><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#upload\");cb.addEventListener('upload-success', function(e) {ajax.post('/uploaded', {id: 'upload', value: e.detail}, null);});cb.addEventListener('upload-progress', function(e) {ajax.post('/uploading', {id: 'upload', value: e.detail}, null);});});</script>", html
  end

end