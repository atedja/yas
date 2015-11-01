# Whitelist hash to only contain a set of keys
#

class YAS::WhitelistExt

  module ClassMethods
    def whitelist *keys
      keys = Array(keys)
      keys.flatten!
      keys.uniq!
      keys.compact!
      keys.each do |k| whitelist_keys << k; end
      whitelist_keys.flatten!
      whitelist_keys.uniq!
      whitelist_keys.compact!
    end

    def whitelist_keys
      @whitelist_keys ||= []
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.whitelist_keys.each do |key|
      subschema.whitelist_keys << key
    end
  end


  def self.apply schema, hash
    hash.delete_if do |k, v|
      !schema.whitelist_keys.include?(k)
    end unless schema.whitelist_keys.empty?
  end


end
