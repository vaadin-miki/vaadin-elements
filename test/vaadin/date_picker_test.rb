require('test_helper') || require_relative('../test_helper')
require 'date'

class Vaadin::DatePickerTest < Minitest::Test

  include Vaadin::ViewHelpers

  # note there is no id in here for test purposes
  class Thing
    attr_accessor :date

    def initialize
      @date = Date.iso8601("2014-04-21")
    end
  end

  def setup
    @someday = Date.iso8601("2012-02-17")
    @thing = Thing.new
  end

  def test_empty
    html = vaadin_date_picker
    assert_equal "<vaadin-date-picker></vaadin-date-picker>", html
  end

  def test_id
    html = vaadin_date_picker(id: "dzień")
    assert_equal "<vaadin-date-picker id=\"dzień\"></vaadin-date-picker>", html
  end

  def test_label
    html = vaadin_date_picker(label: "Pick a date")
    assert_equal "<vaadin-date-picker label=\"Pick a date\"></vaadin-date-picker>", html
  end

  def test_object
    html = vaadin_date_picker(:someday)
    assert_equal %{<vaadin-date-picker id="someday" name="someday" value="2012-02-17"></vaadin-date-picker>}, html
  end

  def test_object_i18n
    html = vaadin_date_picker(:someday, month_names: %w{styczeń luty marzec kwiecień maj czerwiec lipiec sierpień wrzesień październik listopad grudzień})
    assert_equal %{<vaadin-date-picker id="someday" name="someday" value="2012-02-17"></vaadin-date-picker><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#someday");cb.set("i18n.monthNames", ["styczeń","luty","marzec","kwiecień","maj","czerwiec","lipiec","sierpień","wrzesień","październik","listopad","grudzień"]);});</script>}, html
  end

  def test_method
    html = vaadin_date_picker(:thing, :date, id: "this_is_it")
    assert_equal %{<vaadin-date-picker id="this_is_it" name="thing[date]" value="2014-04-21"></vaadin-date-picker>}, html
  end

  def test_method_i18n
    html = vaadin_date_picker(:thing, :date, id: "this_is_it", today: "Now", cancel: "Nevermind!")
    assert_equal %{<vaadin-date-picker id="this_is_it" name="thing[date]" value="2014-04-21"></vaadin-date-picker><script async="false" defer="true">document.addEventListener("WebComponentsReady", function(e) {var cb = document.querySelector("#this_is_it");cb.set("i18n.today", "Now");cb.set("i18n.cancel", "Nevermind!");});</script>}, html
  end

  def test_object_immediate
    html = vaadin_date_picker(:someday, immediate: true)
    assert_equal "<vaadin-date-picker id=\"someday\" name=\"someday\" value=\"2012-02-17\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#someday\");cb.addEventListener('value-changed', function(e) {ajax.post('/someday', {'someday': e.detail.value}, null);});});</script>", html
  end

  def test_object_immediate_verbose
    html = vaadin_date_picker(:someday, immediate: true, verbose_event: true)
    assert_equal "<vaadin-date-picker id=\"someday\" name=\"someday\" value=\"2012-02-17\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#someday\");cb.addEventListener('value-changed', function(e) {ajax.post('/someday', {id: 'someday', value: e.detail.value, name: 'someday', 'someday': e.detail.value}, null);});});</script>", html
  end

  def test_method_immediate_label
    html = vaadin_date_picker(:thing, :date, label: 'Pick a day', immediate: true)
    assert_equal "<vaadin-date-picker id=\"thing_date\" name=\"thing[date]\" label=\"Pick a day\" value=\"2014-04-21\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#thing_date\");cb.addEventListener('value-changed', function(e) {ajax.post('/thing/date', {'thing[date]': e.detail.value}, null);});});</script>", html
  end

  def test_method_immediate_label_verbose
    html = vaadin_date_picker(:thing, :date, label: 'Pick a day', immediate: true, verbose_event: true)
    assert_equal "<vaadin-date-picker id=\"thing_date\" name=\"thing[date]\" label=\"Pick a day\" value=\"2014-04-21\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#thing_date\");cb.addEventListener('value-changed', function(e) {ajax.post('/thing/date', {id: 'thing_date', value: e.detail.value, name: 'thing[date]', 'thing[date]': e.detail.value}, null);});});</script>", html
  end

  def test_method_immediate_callback_verbose
    html = vaadin_date_picker(:thing, :date, immediate: true, use_callback: true, verbose_event: true)
    assert_equal "<vaadin-date-picker id=\"thing_date\" name=\"thing[date]\" value=\"2014-04-21\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#thing_date\");cb.addEventListener('value-changed', function(e) {ajax.post('/thing/date', {id: 'thing_date', value: e.detail.value, name: 'thing[date]', 'thing[date]': e.detail.value}, serverCallbackResponse);});});</script>", html
  end

  def test_method_immediate_callback
    html = vaadin_date_picker(:thing, :date, immediate: true, use_callback: true)
    assert_equal "<vaadin-date-picker id=\"thing_date\" name=\"thing[date]\" value=\"2014-04-21\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#thing_date\");cb.addEventListener('value-changed', function(e) {ajax.post('/thing/date', {'thing[date]': e.detail.value}, serverCallbackResponse);});});</script>", html
  end

  def test_immediate_custom
    html = vaadin_date_picker(label: "Hello", value: "2012-02-17", immediate: '/update/:id', id: 'this')
    assert_equal "<vaadin-date-picker label=\"Hello\" value=\"2012-02-17\" id=\"this\"></vaadin-date-picker><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#this\");cb.addEventListener('value-changed', function(e) {ajax.post('/update/this', {id: 'this', value: e.detail.value}, null);});});</script>", html
  end

end