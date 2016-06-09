require('test_helper') || require_relative('../test_helper')

class Vaadin::GridTest < Minitest::Test

  include Vaadin::ViewHelpers

  class Country
    require 'vaadin/jsonise'
    attr_accessor :code, :name, :english
    include Jsonise

    def initialize(code, name, english)
      @code, @name, @english = code, name, english
    end

    def self.find_all
      [%w{PL Polska Poland}, %w{FI Suomi Finland}, %w{DE Deutschland Germany}, %w{SE Sverige Sweden}].collect { |data| Country.new(*data) }
    end

    def ==(other)
      other.is_a?(Country) && [other.code, other.name, other.english] == [@code, @name, @english]
    end
  end

  class Person
    attr_accessor :nationality

    def initialize(country)
      @nationality = Country.find_all.find { |c| c.code == country }
    end
  end

  def setup
    @countries = Country.find_all
    @country = @countries.find { |c| c.code == 'PL' }
    @person = Person.new('FI')
  end

  def test_empty
    html = vaadin_grid
    assert_equal '<vaadin-grid></vaadin-grid>', html
  end

  def test_id_column_names
    html = vaadin_grid id: 'grid', column_names: %w{foo bar}
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.columns = [{\"name\":\"foo\"},{\"name\":\"bar\"}];});</script>", html
  end

  def test_choices
    html = vaadin_grid @countries, id: 'grid'
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];});</script>", html
  end

  def test_object
    html = vaadin_grid(:country, @countries)
    assert_equal "<vaadin-grid id=\"country\" name=\"country\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#country\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.selection.select(0);});</script>", html
  end

  def test_method
    html = vaadin_grid(:person, :nationality, @countries)
    assert_equal "<vaadin-grid id=\"person_nationality\" name=\"person[nationality]\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#person_nationality\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.selection.select(1);});</script>", html
  end

  def test_columns
    html = vaadin_grid(:country, @countries, column_names: %w{english code})
    assert_equal "<vaadin-grid id=\"country\" name=\"country\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#country\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.selection.select(0);cb.columns = [{\"name\":\"english\"},{\"name\":\"code\"}];});</script>", html
  end

  def test_named_immediate
    html = vaadin_grid(:country, @countries, immediate: true)
    assert_equal "<vaadin-grid id=\"country\" name=\"country\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#country\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.selection.select(0);cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector(\"#country\").selection.selected(function(index){var grItem;document.querySelector(\"#country\").getItem(index, function(err, item){grItem=index;});return grItem;});ajax.post('/country', {id: '', value: JSON.stringify(selection), country: JSON.stringify(selection), name: 'country'}, null);});});</script>", html
  end

  def test_implicit_named_immediate
    html = vaadin_grid @countries, id: 'grid', immediate: true, name: 'country'
    assert_equal "<vaadin-grid id=\"grid\" name=\"country\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector(\"#grid\").selection.selected(function(index){var grItem;document.querySelector(\"#grid\").getItem(index, function(err, item){grItem=index;});return grItem;});ajax.post('/grid', {id: 'grid', value: JSON.stringify(selection), country: JSON.stringify(selection), name: 'country'}, null);});});</script>", html
  end

  def test_choices_immediate
    html = vaadin_grid @countries, id: 'grid', immediate: true
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector(\"#grid\").selection.selected(function(index){var grItem;document.querySelector(\"#grid\").getItem(index, function(err, item){grItem=index;});return grItem;});ajax.post('/grid', {id: 'grid', value: JSON.stringify(selection)}, null);});});</script>", html
  end

  def test_choices_immediate_value_path
    html = vaadin_grid @countries, id: 'grid', immediate: true, item_value_path: 'code'
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector(\"#grid\").selection.selected(function(index){var grItem;document.querySelector(\"#grid\").getItem(index, function(err, item){grItem=item.code;});return grItem;});ajax.post('/grid', {id: 'grid', value: JSON.stringify(selection)}, null);});});</script>", html
  end

  def test_choices_immediate_callback
    html = vaadin_grid @countries, id: 'grid', immediate: true, use_callback: 'gridCallback'
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.addEventListener('selected-items-changed', function(e) {selection = document.querySelector(\"#grid\").selection.selected(function(index){var grItem;document.querySelector(\"#grid\").getItem(index, function(err, item){grItem=index;});return grItem;});ajax.post('/grid', {id: 'grid', value: JSON.stringify(selection)}, gridCallback);});});</script>", html
  end

  def test_lazy_loading
    html = vaadin_grid id: 'grid', lazy_load: '/lazy'
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = function(params, callback) {ajax.post(\"/lazy\", params, function(e) {var json = JSON.parse(e);callback(json.result, json.size);});};});</script>", html
  end

  def test_lazy_loading_string
    html = vaadin_grid :person, :nationality, '/lazy_load', id: 'grid'
    assert_equal "<vaadin-grid id=\"grid\" name=\"person[nationality]\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = function(params, callback) {ajax.post(\"/lazy_load\", params, function(e) {var json = JSON.parse(e);callback(json.result, json.size);});};});</script>", html
  end

end