require('test_helper') || require_relative('../test_helper')

class Vaadin::ElementsTest < Minitest::Test

  include Vaadin::ViewHelpers

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @elements = Vaadin::Elements.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_import
    js = import_vaadin_elements
    assert_equal "<script src=\"https://cdn.vaadin.com/vaadin-core-elements/latest/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>\n<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-combo-box/vaadin-combo-box.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-date-picker/vaadin-date-picker.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-icons/vaadin-icons.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-upload/vaadin-upload.html\" rel=\"import\">", js
  end

  def test_setup
    @elements.grid.items = [{"name": "Ruby", "type": "dynamic"}, {"name": "Java", "type": "static"}]
    @elements.grid.vaadin_events << "value-changed"
    js = setup_vaadin_elements
    assert_equal "document.addEventListener(\"WebComponentsReady\", function (e) {\nvar grid = document.querySelector(\"#grid\");\nif('items' in grid) {\ngrid.items = [{\"name\":\"Ruby\",\"type\":\"dynamic\"},{\"name\":\"Java\",\"type\":\"static\"}]\n};\ngrid.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/grid\", {id: 'grid', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

  def test_setup_custom_event
    @elements.combo = Vaadin::Elements.combo_box
    @elements.combo.vaadin_events << "custom-value-set"
    js = setup_vaadin_elements
    assert_equal "document.addEventListener(\"WebComponentsReady\", function (e) {\nvar combo = document.querySelector(\"#combo\");\n\ncombo.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n\ncombo.addEventListener(\"custom-value-set\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

  def test_setup_custom_event_path
    @elements.combo = Vaadin::Elements.combo_box
    assert @elements.combo.respond_to?(:vaadin_events)
    assert @elements.combo.vaadin_events.is_a?(Hash)
    @elements.combo.vaadin_events["custom-value-set"] = "/:id/has/:event"
    js = setup_vaadin_elements
    assert_equal "document.addEventListener(\"WebComponentsReady\", function (e) {\nvar combo = document.querySelector(\"#combo\");\n\ncombo.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n\ncombo.addEventListener(\"custom-value-set\", function(e) {ajax.post(\"/combo/has/custom-value-set\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

end