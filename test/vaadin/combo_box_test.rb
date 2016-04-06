require('test_helper') || require_relative('../test_helper')

class Vaadin::ComboBoxTest < Minitest::Test

  include Vaadin::ViewHelpers

  class Place
    attr_accessor :country
    def initialize
      @country = "Poland"
    end
    def id
      666
    end
  end

  class City
    require 'vaadin/jsonise'
    attr_accessor :code, :name
    include Jsonise
    def initialize(code, name)
      @code, @name = code, name
    end
    def self.find_all
      [%w{GDN Gdańsk}, %w{TKU Turku}, %w{MUC Muenchen}].collect {|data| City.new(data.first, data.last)}
    end
  end

  def setup
    @countries = %w{Poland Finland Germany}
    @place = "Finland"
    @big_place = Place.new
    @cities = City.find_all
    @city = @cities.last
  end

  def test_empty
    html = vaadin_combo_box
    assert_equal "<vaadin-combo-box></vaadin-combo-box>", html
  end

  def test_id_only
    html = vaadin_combo_box({id: "box"})
    assert_equal "<vaadin-combo-box id=\"box\"></vaadin-combo-box>", html
  end

  def test_choices
    html = vaadin_combo_box(:person, :country, @countries)
    assert_equal %{<vaadin-combo-box id="person_country" name="person[country]"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#person_country");cb.items = ["Poland","Finland","Germany"];});</script>}, html
  end

  def test_choices_only_fails
    assert_raises RuntimeError do
      html = vaadin_combo_box(@countries)
    end
  end

  def test_choices_no_method
    html = vaadin_combo_box(:country, @countries)
    assert_equal %{<vaadin-combo-box id="country" name="country"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#country");cb.items = ["Poland","Finland","Germany"];});</script>}, html
  end

  def test_choices_no_method_value
    html = vaadin_combo_box(:place, @countries)
    assert_equal %{<vaadin-combo-box id="place" name="place"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#place");cb.items = ["Poland","Finland","Germany"];cb.value = "Finland";});</script>}, html
  end

  def test_label_no_method
    html = vaadin_combo_box(:country, @countries, {label: "Pick a country:"})
    assert_equal %{<vaadin-combo-box id="country" name="country" label="Pick a country:"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#country");cb.items = ["Poland","Finland","Germany"];});</script>}, html
  end

  def test_label_method
    html = vaadin_combo_box(:person, :country, @countries, {label: "Pick a country:"})
    assert_equal %{<vaadin-combo-box id="person_country" name="person[country]" label="Pick a country:"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#person_country");cb.items = ["Poland","Finland","Germany"];});</script>}, html
  end

  def test_method_value
    html = vaadin_combo_box(:big_place, :country, @countries)
    assert_equal %{<vaadin-combo-box id="big_place_country" name="big_place[country]"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#big_place_country");cb.items = ["Poland","Finland","Germany"];cb.value = "Poland";});</script>}, html
  end

  def test_immediate_no_id_fails
    assert_raises RuntimeError do
      html = vaadin_combo_box(immediate: true)
    end
  end

  def test_immediate_id_only
    html = vaadin_combo_box(id: "box", immediate: true)
    assert_equal %{<vaadin-combo-box id="box"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#box");cb.addEventListener('value-changed', function(e) {ajax.post('/box', {id: 'box', value: e.detail.value}, serverCallbackResponse);});});</script>}, html
  end

  def test_immediate_object_options
    html = vaadin_combo_box(:country, @countries, {label: "Pick a country:", immediate: true})
    assert_equal %{<vaadin-combo-box id="country" name="country" label="Pick a country:"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#country");cb.items = ["Poland","Finland","Germany"];cb.addEventListener('value-changed', function(e) {ajax.post('/country', {id: 'country', value: e.detail.value}, serverCallbackResponse);});});</script>}, html
  end

  def test_immediate_object_value
    html = vaadin_combo_box(:big_place, :country, @countries, immediate: true)
    assert_equal %{<vaadin-combo-box id="big_place_country" name="big_place[country]"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#big_place_country");cb.items = ["Poland","Finland","Germany"];cb.value = "Poland";cb.addEventListener('value-changed', function(e) {ajax.post('/big_place/666/country', {id: 'big_place_country', value: e.detail.value}, serverCallbackResponse);});});</script>}, html
  end

  def test_immediate_path
    html = vaadin_combo_box(id: "box", immediate: "/~")
    assert_equal %{<vaadin-combo-box id="box"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#box");cb.addEventListener('value-changed', function(e) {ajax.post('/~', {id: 'box', value: e.detail.value}, serverCallbackResponse);});});</script>}, html
  end

  def test_immediate_path_replaced
    html = vaadin_combo_box(id: "box", immediate: "/~:id")
    assert_equal %{<vaadin-combo-box id="box"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#box");cb.addEventListener('value-changed', function(e) {ajax.post('/~box', {id: 'box', value: e.detail.value}, serverCallbackResponse);});});</script>}, html
  end

  def test_path
    html = vaadin_combo_box(:city, @cities, item_label_path: "name", item_value_path: "code")
    assert_equal %{<vaadin-combo-box id="city" name="city" item-label-path="name" item-value-path="code"></vaadin-combo-box><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#city");cb.items = [{"code":"GDN","name":"Gdańsk"},{"code":"TKU","name":"Turku"},{"code":"MUC","name":"Muenchen"}];cb.value = "MUC";});</script>}, html
  end

end
