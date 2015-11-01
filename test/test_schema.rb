require './test/helper.rb'


class MigrateSchema < YAS::Schema
  migrate :names do |v|
    v = Array(v) if !v.is_a?(Array)
    v
  end
end


class InheritedSchema < MigrateSchema
  rename :book => :books
end


class ComplexSchema < MigrateSchema

  whitelist :name, :contact_name, :contact_email, :redirect_uris, :active

  attribute :name do
    required
    type String
  end

  attribute :contact_name do
    required
    type String
  end

  rename :email => :contact_email
  attribute :contact_email do
    required
    type String
  end

  rename :redirect_uri => :redirect_uris
  attribute :redirect_uris do
    required
    type Array
    auto_convert
  end
  migrate :redirect_uris do |v|
    v = Array(v) if !v.is_a?(Array)
    v
  end

  attribute :active do
    required
    type TrueClass
    auto_convert
    default { true }
  end

end


class TestSchema < Minitest::Test

  def test_validate_not_bang_does_not_overwrite_original
    hash = {
      names: "john",
    }
    result = hash.validate MigrateSchema
    assert_equal ["john"], result[:names]
    assert_equal "john", hash[:names]
  end

  def test_inherited_schema_should_inherit_extensions
    hash = {
      names: "john",
      book: "Dolly",
    }
    hash.validate! InheritedSchema
    assert_equal ["john"], hash[:names]
    assert_equal "Dolly", hash[:books]
    assert_nil hash[:book]
  end

  def test_complex_schema
    hash = {
      name: "john",
      contact_name: "someone else",
      email: "jdoe@example.com",
      redirect_uri: "jdoe.com",
      active: 1,
    }
    hash.validate! ComplexSchema
    assert_equal "john", hash[:name]
    assert_equal "someone else", hash[:contact_name]
    assert_equal "jdoe@example.com", hash[:contact_email]
    assert_nil hash[:email]
    assert_equal ["jdoe.com"], hash[:redirect_uris]
    assert_equal true, hash[:active]
  end

end
