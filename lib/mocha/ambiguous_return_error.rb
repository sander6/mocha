module Mocha
  class AmbiguousReturnError < StandardError
    
    def message
      "You set an expectation with a static return value and provided a block, making the desired return value ambiguous.\n" +
      "If you want the return value to be dynamically generated from the arguments, use stub(:method).returns { |*args| ... }"
    end
    
  end
end