require './test/helper.rb'

class RenameSchema < YAS::Schema
  rename :addr => :address
  rename 'home' => 'office'
end



class TestRenameExt < Minitest::Test

  def test_rename_ext
    hash = {
      addr: "Some address",
      'home' => 'home address',
      untouched: "Nothing"
    }
    hash.validate! RenameSchema
    assert_equal "Some address", hash[:address]
    assert_equal "home address", hash['office']
    assert_equal "Nothing", hash[:untouched]
    assert_nil hash[:addr]
  end

end
