# Symbolize keys
#

class YAS::SymbolizeExt

  module ClassMethods
    def symbolize sym = nil
      @symbolize = sym if (!sym.nil? && (sym.class == TrueClass || sym.class == FalseClass))
      @symbolize = false unless defined? @symbolize
      @symbolize
    end
  end


  def self.when_used schema
    schema.extend ClassMethods
  end


  def self.when_schema_inherited superschema, subschema
    subschema.symbolize(superschema.symbolize)
  end


  def self.apply schema, hash
    hash.keys.each do |key|
      hash[(key.to_sym rescue key) || key] = hash.delete(key)
    end if schema.symbolize
  end

end
