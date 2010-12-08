require 'mocha/is_a'
require 'mocha/ambiguous_return_error'

module Mocha # :nodoc:
  
  class SingleReturnValue # :nodoc:
    
    def initialize(value = nil, &block)
      @block = if block_given?
        raise Mocha::AmbiguousReturnError unless value.nil?
        block
      else
        lambda { value }
      end
    end
    
    def evaluate(*arguments)
      @block.call(*arguments)
    end
    
  end
  
end
