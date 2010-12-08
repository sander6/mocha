module Mocha
  class SymbolThrower
    
    def initialize(symbol, object = nil)
      @symbol, @object = symbol, object
    end
    
    def evaluate(*arguments)
      @object.nil? ? throw(@symbol) : throw(@symbol, @object)
    end
    
  end
end