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
      rename_keys.merge!(map)
    end

    def rename_keys
      @rename_keys ||= {}
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.rename_keys.each do |from, to|
      subschema.rename_keys[key] = to
    end
  end


  def self.apply schema, hash
    schema.rename_keys.each do |from, to|
      if hash.has_key?(from)
        hash[to] = hash[from]
        hash.delete(from)
      end
    end
  end

end
