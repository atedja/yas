require './test/helper.rb'

class RenameSchema < YAS::Schema
  rename :addr => :address
end


class TestRenameExt < Minitest::Test

  def test_rename_ext
    hash = {
      addr: "Some address",
      untouched: "Nothing"
    }
    hash.validate! RenameSchema
    assert_equal "Some address", hash[:address]
    assert_equal "Nothing", hash[:untouched]
    assert_nil hash[:addr]
    assert_equal 2, hash.length
  end

end
