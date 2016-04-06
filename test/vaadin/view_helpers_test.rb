require('test_helper') || require_relative('../test_helper')

class Vaadin::ElementsTest < Minitest::Test

  include Vaadin::ViewHelpers

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @elements = Vaadin::Elements.new
    @countries = %w{Poland Finland Germany}
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_import
    js = import_vaadin_elements
    assert_equal "<script src=\"http://polygit2.appspot.com/polymer+v1.3.1/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/components/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>\n<link href=\"http://polygit2.appspot.com/polymer+v1.3.1/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/components/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+v1.3.1/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/components/vaadin-combo-box/vaadin-combo-box.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+v1.3.1/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/components/vaadin-date-picker/vaadin-date-picker.html\" rel=\"import\">", js
  end

  def test_setup
    @elements.grid.items = [{"name": "Ruby", "type": "dynamic"}, {"name": "Java", "type": "static"}]
    @elements.grid.vaadin_events << "value-changed"
    js = setup_vaadin_elements
    assert_equal "function serverCallbackResponse(e) {\n\n         console.log(e);\n\n         var resp = JSON.parse(e);\n\n         for(var oid in resp) {\n\n           var comp = document.querySelector('#'+oid);\n\n           for(var meth in resp[oid]) {\n\n             if(meth in comp) {\n\n             comp[meth] = resp[oid][meth];\n\n       }}}};\ndocument.addEventListener(\"WebComponentsReady\", function (e) {\nvar grid = document.querySelector(\"#grid\");\nif('items' in grid) {\ngrid.items = [{\"name\":\"Ruby\",\"type\":\"dynamic\"},{\"name\":\"Java\",\"type\":\"static\"}]\n};\ngrid.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/grid\", {id: 'grid', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

  def test_setup_custom_event
    @elements.combo = Vaadin::Elements.combo_box
    @elements.combo.vaadin_events << "custom-value-set"
    js = setup_vaadin_elements
    assert_equal "function serverCallbackResponse(e) {\n\n         console.log(e);\n\n         var resp = JSON.parse(e);\n\n         for(var oid in resp) {\n\n           var comp = document.querySelector('#'+oid);\n\n           for(var meth in resp[oid]) {\n\n             if(meth in comp) {\n\n             comp[meth] = resp[oid][meth];\n\n       }}}};\ndocument.addEventListener(\"WebComponentsReady\", function (e) {\nvar combo = document.querySelector(\"#combo\");\n\ncombo.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n\ncombo.addEventListener(\"custom-value-set\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

  def test_setup_custom_event_path
    @elements.combo = Vaadin::Elements.combo_box
    assert @elements.combo.respond_to?(:vaadin_events)
    assert @elements.combo.vaadin_events.is_a?(Hash)
    @elements.combo.vaadin_events["custom-value-set"] = "/:id/has/:event"
    js = setup_vaadin_elements
    assert_equal "function serverCallbackResponse(e) {\n\n         console.log(e);\n\n         var resp = JSON.parse(e);\n\n         for(var oid in resp) {\n\n           var comp = document.querySelector('#'+oid);\n\n           for(var meth in resp[oid]) {\n\n             if(meth in comp) {\n\n             comp[meth] = resp[oid][meth];\n\n       }}}};\ndocument.addEventListener(\"WebComponentsReady\", function (e) {\nvar combo = document.querySelector(\"#combo\");\n\ncombo.addEventListener(\"value-changed\", function(e) {ajax.post(\"~/combo\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n\ncombo.addEventListener(\"custom-value-set\", function(e) {ajax.post(\"/combo/has/custom-value-set\", {id: 'combo', value: e.detail.value}, serverCallbackResponse)});\n});", js
  end

  def test_combo_box_empty
    html = vaadin_combo_box
    assert_equal "<vaadin-combo-box></vaadin-combo-box>", html
  end

  def test_combo_box_id_only
    html = vaadin_combo_box({id: "box"})
    assert_equal "<vaadin-combo-box id=\"box\"></vaadin-combo-box>", html
  end

  def test_combo_box_choices
    html = vaadin_combo_box(:person, :country, @countries)
    assert_equal "<vaadin-combo-box id=\"person_country\" name=\"person[country]\"></vaadin-combo-box><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {\n  var cb = document.querySelector(\"#person_country\");\n  cb.items = [\"Poland\",\"Finland\",\"Germany\"];\n});\n</script>", html
  end

  def test_combo_box_choices_no_method
    html = vaadin_combo_box(:country, @countries)
    assert_equal "<vaadin-combo-box id=\"country\" name=\"country\"></vaadin-combo-box><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {\n  var cb = document.querySelector(\"#country\");\n  cb.items = [\"Poland\",\"Finland\",\"Germany\"];\n});\n</script>", html
  end

  def test_combo_box_custom_label
    html = vaadin_combo_box(:country, @countries, {label: "Pick a country:"})
    assert_equal "<vaadin-combo-box id=\"country\" name=\"country\" label=\"Pick a country:\"></vaadin-combo-box><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {\n  var cb = document.querySelector(\"#country\");\n  cb.items = [\"Poland\",\"Finland\",\"Germany\"];\n});\n</script>", html
  end

end