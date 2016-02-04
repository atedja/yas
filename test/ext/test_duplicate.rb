require './test/helper.rb'

class DuplicateSchema < YAS::Schema
  duplicate :addr => :address
  duplicate 'home' => ['office', :temp]
end



class TestDuplicateExt < Minitest::Test

  def test_duplicate_ext
    hash = {
      addr: "Some address",
      'home' => 'home address',
      untouched: "Nothing"
    }
    hash.validate! DuplicateSchema
    assert_equal "Some address", hash[:addr]
    assert_equal "Some address", hash[:address]
    assert_equal "home address", hash['home']
    assert_equal "home address", hash['office']
    assert_equal "home address", hash[:temp]
    assert_equal "Nothing", hash[:untouched]
  end

end
