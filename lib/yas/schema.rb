class YAS::SchemaBase

  def self.use ext
    raise YAS::ExtensionError, "Duplicate Extension. Extension #{ext} is already used." if exts.include?(ext)
    raise YAS::ExtensionError, "Wrong Extension Format" unless ext.respond_to?(:apply) && ext.respond_to?(:when_used)
    exts << ext
    ext.when_used(self)
  end


  def self.exts
    @exts ||= []
  end


  def self.validate hash
    exts.each do |ext|
      ext.apply(self, hash)
    end
    hash
  end


  def self.inspect
    exts.inspect
  end


  # Inherited hook to inherit all extensions.
  def self.inherited subclass
    exts.each do |ext|
      subclass.use(ext)
      ext.when_schema_inherited(self, subclass) if ext.respond_to?(:when_schema_inherited)
    end
  end

end

class YAS::Schema < YAS::SchemaBase

  use YAS::SymbolizeExt
  use YAS::RenameExt
  use YAS::DuplicateExt
  use YAS::WhitelistExt
  use YAS::MigrateExt
  use YAS::AttributeExt

end
