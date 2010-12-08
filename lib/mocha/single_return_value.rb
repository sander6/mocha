require 'mocha/is_a'

module Mocha # :nodoc:
  
  class SingleReturnValue # :nodoc:
    
    def initialize(value)
      @value = value
    end
    
    def evaluate(*arguments)
      @value
    end
    
  end
  
end
