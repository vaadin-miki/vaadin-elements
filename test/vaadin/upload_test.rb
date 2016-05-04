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

  def test_i18n_files_direct
    html = vaadin_upload '/here', id: 'upload', i18n: {drop_files_here: 'Przeciągnij pliki tutaj', cancel: 'Anuluj'}
    assert_equal %{<vaadin-upload id="upload" target="/here"></vaadin-upload><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#upload");cb.i18n.dropFilesHere = "Przeciągnij pliki tutaj";cb.i18n.cancel = "Anuluj";});</script>}, html
  end

  def test_i18n_errors
    html = vaadin_upload '/here', id: 'upload', i18n: {error: {too_many_files: 'Za dużo plików!'}}
    assert_equal %{<vaadin-upload id="upload" target="/here"></vaadin-upload><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#upload");cb.i18n.error.tooManyFiles = "Za dużo plików!";});</script>}, html
  end

end