require './test/helper.rb'


class SymbolizedSchema < YAS::Schema
  symbolize true
end

class NotSymbolizedSchema < YAS::Schema
  attribute :first_name do
    required
    type String
  end
end


class TestSymbolizeExt < Minitest::Test

  def test_symbolize
    hash = {
      'first_name' => "john",
      'last_name' => "doe",
    }
    hash.validate! SymbolizedSchema
    assert_equal "john", hash[:first_name]
    assert_equal "doe", hash[:last_name]
    assert_nil hash['first_name']
    assert_nil hash['last_name']
  end

  def test_not_symbolize
    hash = {
      'first_name' => "john",
    }
    assert_raises YAS::ValidationError do
      hash.validate! NotSymbolizedSchema
    end
  end

end
