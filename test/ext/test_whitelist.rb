require './test/helper.rb'


class WhitelistSchema < YAS::Schema
  whitelist :first_name, :last_name, :address
end


class TestWhitelistExt < Minitest::Test

  def test_whitelist_ext
    hash = {
      first_name: "john",
      last_name: "doe",
      address: "123 Main St",
      invalid: "will get removed",
    }
    hash.validate! WhitelistSchema
    assert_equal "john", hash[:first_name]
    assert_equal "doe", hash[:last_name]
    assert_equal "123 Main St", hash[:address]
    assert_nil hash[:invalid]
  end

end
