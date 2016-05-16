require('test_helper') || require_relative('../test_helper')

class Vaadin::ElementsTest < Minitest::Test

  include Vaadin::ViewHelpers

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_import
    js = import_vaadin_elements
    assert_equal "<script src=\"https://cdn.vaadin.com/vaadin-core-elements/latest/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>\n<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-combo-box/vaadin-combo-box.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-date-picker/vaadin-date-picker.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-icons/vaadin-icons.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-upload/vaadin-upload.html\" rel=\"import\">", js
  end

  def test_selective_import
    js = import_vaadin_elements 'vaadin-grid', 'vaadin-combo-box'
    assert_equal "<script src=\"https://cdn.vaadin.com/vaadin-core-elements/latest/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"https://cdn.vaadin.com/vaadin-core-elements/master/vaadin-combo-box/vaadin-combo-box.html\" rel=\"import\">", js
  end

  def test_polygit
    js = import_through_polygit
    assert_equal "<script src=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>\n<script src=\"http://momentjs.com/downloads/moment.min.js\"></script>\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/vaadin-combo-box/vaadin-combo-box.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/vaadin-date-picker/vaadin-date-picker.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/vaadin-icons/vaadin-icons.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-combo-box+vaadin+*/vaadin-date-picker+vaadin+*/vaadin-icons+vaadin+*/vaadin-upload+vaadin+*/components/vaadin-upload/vaadin-upload.html\" rel=\"import\">", js
  end

  def test_selective_polygit
    js = import_through_polygit 'vaadin-grid', 'vaadin-icons'
    assert_equal "<script src=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-icons+vaadin+*/components/webcomponentsjs/webcomponents-lite.min.js\"></script>\n<script src=\"https://raw.githubusercontent.com/vaadin-miki/vaadin-elements-jsrubyconnector/master/connector.js\"></script>\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-icons+vaadin+*/components/vaadin-grid/vaadin-grid.html\" rel=\"import\">\n<link href=\"http://polygit2.appspot.com/polymer+:master/vaadin-grid+vaadin+*/vaadin-icons+vaadin+*/components/vaadin-icons/vaadin-icons.html\" rel=\"import\">", js
  end

end