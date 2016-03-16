require('test_helper') || require_relative('../test_helper')

class Vaadin::JsoniseTest < Minitest::Test

  class Model
    include Jsonise
    attr_accessor :text, :number
  end

  class VirtualModel
    include Jsonise
    attr_accessor :text, :number
    json_virtual_attributes :sentence

    def sentence
      "#{text} with a number #{number}"
    end

    def sentence=
      raise "This is never called!"
    end
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @model = Model.new
    @model.text = "Something"
    @model.number = 42
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_to_json
    assert_equal "{\"number\":42,\"text\":\"Something\"}", @model.to_json
  end

  def test_from_json
    @other = Model.new.from_json("{\"number\":42,\"text\":\"Something\"}")
    assert_equal(@model.text, @other.text)
    assert_equal(@model.number, @other.number)
  end

  def test_array_to_json
    assert_equal "[{\"number\":42,\"text\":\"Something\"}]", [@model].to_json
  end

  def test_virtual_to_from_json
    model = VirtualModel.new
    model.text = "The ultimate solution to any problem."
    model.number = 42
    json = model.to_json
    assert_equal "{\"number\":42,\"sentence\":\"The ultimate solution to any problem. with a number 42\",\"text\":\"The ultimate solution to any problem.\"}", json

    restored = Model.new.from_json(json)
    assert_equal model.text, restored.text
    assert_equal model.number, restored.number
  end

end