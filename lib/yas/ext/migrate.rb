# Migrate the value of a key
#

class YAS::MigrateExt

  module ClassMethods

    def migrate key, &block
      migrate_keys[key] = block
    end


    def migrate_keys
      @migrate_keys ||= {}
    end

  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    superschema.migrate_keys.each do |key, pr|
      subschema.migrate_keys[key] = pr
    end
  end


  def self.apply schema, hash
    schema.migrate_keys.each do |key, pr|
      hash.has_key?(key) and
        hash[key] = pr.call(hash[key])
    end
  end

end
