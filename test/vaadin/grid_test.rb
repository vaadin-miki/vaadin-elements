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
    @country = @countries.find { |c| c.code == "PL" }
    @person = Person.new("FI")
  end

  def test_empty
    html = vaadin_grid
    assert_equal "<vaadin-grid></vaadin-grid>", html
  end

  def test_choices
    html = vaadin_grid @countries, id: "grid"
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

  def test_choices_immediate
    html = vaadin_grid @countries, id: "grid", immediate: true
    assert_equal "<vaadin-grid id=\"grid\"></vaadin-grid><script async=\"false\" defer=\"true\">document.addEventListener(\"WebComponentsReady\", function(e) {var cb = document.querySelector(\"#grid\");cb.items = [{\"code\":\"PL\",\"english\":\"Poland\",\"name\":\"Polska\"},{\"code\":\"FI\",\"english\":\"Finland\",\"name\":\"Suomi\"},{\"code\":\"DE\",\"english\":\"Germany\",\"name\":\"Deutschland\"},{\"code\":\"SE\",\"english\":\"Sweden\",\"name\":\"Sverige\"}];cb.addEventListener('selected-items-changed', function(e) {ajax.post('/grid', {id: 'grid', value: e.detail.value}, serverCallbackResponse);});});</script>", html
  end

end