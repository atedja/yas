# Duplicate value of a key
#
# Usage:
#
# duplicate :mykey => [:other_key, :another_key]
#

class YAS::DuplicateExt

  module ClassMethods
    def duplicate map
      duplicate_keys.merge!(map)
    end

    def duplicate_keys
      @duplicate_keys ||= {}
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.duplicate_keys.each do |from, to|
      subschema.duplicate_keys[key] = to
    end
  end


  def self.apply schema, hash
    schema.duplicate_keys.each do |from, to|
      if hash.has_key?(from)
        to = Array(to)
        to.each { |t| hash[t] = hash[from] }
      end
    end
  end

end
