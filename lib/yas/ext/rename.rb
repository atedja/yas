# Rename keys from one to another
#
# Usage:
#
# To rename `fname` to `first_name`, and `lname` to `last_name`
# rename :fname => :first_name, :lname => :last_name
#

class YAS::RenameExt

  module ClassMethods
    def rename map
      smap = YAS.symbolize(map)
      rename_keys.merge!(smap)
    end

    def rename_keys
      @rename_keys ||= {}
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.rename_keys.each do |from, value|
      subschema.rename_keys[key] = value
    end
  end


  def self.apply schema, hash
    schema.rename_keys.each do |from, to|
      hash.has_key?(from) and
        hash[to] = hash[from] and
        hash.delete(from)
    end
  end

end
