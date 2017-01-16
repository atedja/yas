class Hash

  def validate schema
    copy = Hash[self]
    schema.validate(copy) if schema.respond_to?(:validate)
  end


  def validate! schema
    schema.validate(self) if schema.respond_to?(:validate)
  end


  def slice *keys
    keys.flatten!
    data = keys.inject({}) do |memo, key|
      memo[key] = self[key] if self[key]
      memo
    end
    data
  end

end
