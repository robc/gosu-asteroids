class AssetManager
  def initialize()
    @assets = Hash.new
  end

  def method_missing(symbol, *args, &block)
    case symbol.to_s
    when /(.*)=/
      @assets[$1.to_sym] = args[0]
    else
      return @assets[symbol]
    end
  end
end