require './test/helper.rb'


class MigrateSchema < YAS::Schema
  migrate :names do |v|
    v = Array(v) if !v.is_a?(Array)
    v
  end
end


class TestMigrateExt < Minitest::Test

  def test_migrate_ext
    hash = {
      names: "john"
    }
    hash.validate! MigrateSchema
    assert_equal ["john"], hash[:names]
  end

end
