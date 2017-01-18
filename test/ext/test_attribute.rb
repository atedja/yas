require './test/helper.rb'

class TestAttribute < Minitest::Test

  Attribute = YAS::AttributeExt::Attribute

  def test_required
    attr = Attribute.new(:batman).required
    assert_equal true, attr.required?
  end


  def test_type
    attr = Attribute.new(:batman).type(String)
    assert_equal "hello", attr.validate("hello")
    assert_raises YAS::ValidationError do
      attr.validate(1)
    end
  end


  def test_auto_convert_integer
    attr = Attribute.new(:batman).type(Integer).auto_convert
    assert_equal 1000, attr.validate(1000)
    assert_equal 1000, attr.validate("1000")
  end


  def test_auto_convert_float
    attr = Attribute.new(:batman).type(Float).auto_convert
    assert_equal 1000.01, attr.validate(1000.01)
    assert_equal 1000.01, attr.validate("1000.01")
  end


  def test_auto_convert_string
    attr = Attribute.new(:batman).type(String).auto_convert
    assert_equal "hello", attr.validate("hello")
    assert_equal "1", attr.validate(1)
  end


  def test_auto_convert_array
    attr = Attribute.new(:batman).type(Array).auto_convert
    assert_equal ["hello"], attr.validate(["hello"])
    assert_equal [1], attr.validate(1)
  end


  def test_auto_convert_time
    attr = Attribute.new(:batman).type(Time).auto_convert
    time = attr.validate("2014/7/14")
    assert time.is_a?(Time)
    assert_equal 2014, time.year
    assert_equal 7, time.month
    assert_equal 14, time.day

    time = attr.validate(Time.now.utc)
    assert time
  end


  def test_auto_convert_boolean
    attr = Attribute.new(:batman).type(TrueClass).auto_convert
    assert_equal false, attr.validate("false")
    assert_equal false, attr.validate("123")
    assert_equal true, attr.validate(1)
    assert_equal true, attr.validate("true")
    assert_equal true, attr.validate("1")
    assert_equal false, attr.validate(0)
    assert_equal false, attr.validate(nil)
  end


  def test_default
    attr = Attribute.new(:batman).default { "John" }
    assert_equal "John", attr.validate(nil)
  end


  def test_has_default
    attr = Attribute.new(:batman).default { "John" }
    assert_equal true, attr.has_default?

    no_default_attr = Attribute.new(:batman)
    assert_equal false, no_default_attr.has_default?
  end


  def test_alter
    attr = Attribute.new(:batman).alter { |v| v.uniq!; v.compact!; v }
    value = attr.validate(["Jim", "John", "Jim", "Kim", "Sally"])
    assert_equal ["Jim", "John", "Kim", "Sally"], value
  end


  def test_validate_value
    attr = Attribute.new(:batman).validate_value { |v| v == "John" }
    assert_raises YAS::ValidationError do
      attr.validate("Jim")
    end
    attr.validate("John")
  end


  def test_all
    attr = Attribute.new(:batman)
      .required
      .type(Integer)
      .default { 0 }
      .validate_value { |v| v >= 0 }

    assert_equal true, attr.required?
    assert_equal 0, attr.validate(nil)
    assert_equal 100, attr.validate(100)
    assert_raises YAS::ValidationError do
      attr.validate(-100)
    end
  end


  def test_validate_maintain_value_if_type_not_specified
    attr = Attribute.new(:batman)
    [true, false, :symbol, 1, 0, -1, 10.0, "string", 1293.1, 0x90, Time.now].each do |v|
      assert_equal v, attr.validate(v)
    end

    assert_nil attr.validate(nil)
  end

end


class AttributeSchema < YAS::Schema

  key :name do
    required
    type String
    auto_convert
    default { "joe" }
    validate_value { |v| v.length < 10 }
  end

  key :number do
    required
    type Integer
    auto_convert
  end

  key 'geo' do
    type Float
    auto_convert
  end

end


class NestedAttributeSchema < YAS::Schema

  key :personal_info do
    required
    type AttributeSchema
  end

end


class MultipleAttributesSchema < YAS::Schema

  key :personal_info, "other_info" do
    required
    type String
  end

end


class TestAttributeExt < Minitest::Test

  def test_attribute_ext
    hash = {
      name: "someone",
      number: 10,
      'geo' => '10.20',
    }
    hash.validate! AttributeSchema
    assert_equal "someone", hash[:name]
    assert_equal 10.20, hash['geo']
  end


  def test_attribute_ext_validate_value
    hash = {
      name: "someone with long name",
      number: 99,
    }
    assert_raises YAS::ValidationError do
      hash.validate! AttributeSchema
    end
  end


  def test_attribute_ext_autoconvert_and_nil_attribute
    hash = {
      name: nil,
      number: "10"
    }
    hash.validate! AttributeSchema
    assert_equal 10, hash[:number]
    assert_equal "joe", hash[:name]
  end


  def test_nested_attribute_schema
    hash = {
      personal_info: {
        name: nil,
        number: "10"
      }
    }
    hash.validate! NestedAttributeSchema
    assert_equal 10, hash[:personal_info][:number]
    assert_equal "joe", hash[:personal_info][:name]
  end

  def test_multiple_attributes_with_same_block
    hash = {
      personal_info: "when",
      "other_info" => "who"
    }
    hash.validate! MultipleAttributesSchema
    assert_equal "when", hash[:personal_info]
    assert_equal "who", hash["other_info"]

    hash = {
      personal_info: "when",
    }
    assert_raises YAS::ValidationError do
      hash.validate! MultipleAttributesSchema
    end
  end

end
