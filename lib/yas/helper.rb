module YAS

  def self.symbolize hash
    hash.inject({}) do |memo,(k,v)|
      memo[k.to_sym] = v
      memo
    end
  end

end
