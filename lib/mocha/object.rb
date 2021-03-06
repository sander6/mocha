require 'mocha/mockery'
require 'mocha/instance_method'
require 'mocha/class_method'
require 'mocha/module_method'
require 'mocha/any_instance_method'
require 'mocha/argument_iterator'

module Mocha
  
  # Methods added all objects to allow mocking and stubbing on real objects.
  #
  # Methods return a Mocha::Expectation which can be further modified by methods on Mocha::Expectation.
  module ObjectMethods
  
    def mocha # :nodoc:
      @mocha ||= Mocha::Mockery.instance.mock_impersonating(self)
    end
  
    def reset_mocha # :nodoc:
      @mocha = nil
    end
  
    def stubba_method # :nodoc:
      Mocha::InstanceMethod
    end
  
    def stubba_object # :nodoc:
      self
    end
  
    # :call-seq: expects(method_name) -> expectation
    #            expects(method_names_vs_return_values) -> last expectation
    #
    # Adds an expectation that a method identified by +method_name+ Symbol must be called exactly once with any parameters.
    # Returns the new expectation which can be further modified by methods on Mocha::Expectation.
    #   product = Product.new
    #   product.expects(:save).returns(true)
    #   assert_equal true, product.save
    #
    # The original implementation of <tt>Product#save</tt> is replaced temporarily.
    #
    # The original implementation of <tt>Product#save</tt> is restored at the end of the test.
    #
    # If +method_names_vs_return_values+ is a +Hash+, an expectation will be set up for each entry using the key as +method_name+ and value as +return_value+.
    #   product = Product.new
    #   product.expects(:valid? => true, :save => true)
    #
    #   # exactly equivalent to
    #
    #   product = Product.new
    #   product.expects(:valid?).returns(true)
    #   product.expects(:save).returns(true)
    def expects(method_name_or_hash)
      expectation = nil
      mockery = Mocha::Mockery.instance
      iterator = ArgumentIterator.new(method_name_or_hash)
      iterator.each { |*args|
        method_name = args.shift
        mockery.on_stubbing(self, method_name)
        method = stubba_method.new(stubba_object, method_name)
        mockery.stubba.stub(method)
        expectation = mocha.expects(method_name, caller)
        expectation.returns(args.shift) if args.length > 0
      }
      expectation
    end
  
    # :call-seq: stubs(method_name) -> expectation
    #            stubs(method_names_vs_return_values) -> last expectation
    #
    # Adds an expectation that a method identified by +method_name+ Symbol may be called any number of times with any parameters.
    # Returns the new expectation which can be further modified by methods on Mocha::Expectation.
    #   product = Product.new
    #   product.stubs(:save).returns(true)
    #   assert_equal true, product.save
    #
    # The original implementation of <tt>Product#save</tt> is replaced temporarily.
    #
    # The original implementation of <tt>Product#save</tt> is restored at the end of the test.
    #
    # If +method_names_vs_return_values+ is a +Hash+, an expectation will be set up for each entry using the key as +method_name+ and value as +return_value+.
    #   product = Product.new
    #   product.stubs(:valid? => true, :save => true)
    #
    #   # exactly equivalent to
    #
    #   product = Product.new
    #   product.stubs(:valid?).returns(true)
    #   product.stubs(:save).returns(true)
    def stubs(method_name_or_hash)
      expectation = nil
      mockery = Mocha::Mockery.instance
      iterator = ArgumentIterator.new(method_name_or_hash)
      iterator.each { |*args|
        method_name = args.shift
        mockery.on_stubbing(self, method_name)
        method = stubba_method.new(stubba_object, method_name)
        mockery.stubba.stub(method)
        expectation = mocha.stubs(method_name, caller)
        expectation.returns(args.shift) if args.length > 0
      }
      expectation
    end
    
    # :call-seq: unstub(*method_names)
    #
    # Removes the method stub added by calls to #expects or #stubs.
    # Restores the original behaviour of the method before it was stubbed.
    #   multiplier = Multiplier.new
    #   multiplier.double(2) # => 4
    #   multiplier.stubs(:double).raises
    #   multiplier.double(2) # => raises exception
    #   multiplier.unstubs(:double)
    #   multiplier.double(2) # => 4
    #
    # The original implementation of <tt>Multiplier#double</tt> is replaced temporarily.
    #
    # The original implementation of <tt>Multiplier#double</tt> is restored when #unstub is called.
    #
    # WARNING: If you #unstub a method which still has unsatisfied expectations, you may be removing
    # the only way those expectations can be satisfied. Use #unstub with care.
    #
    # If multiple +method_names+ are supplied, each method is unstubbed.
    #   multiplier.unstub(:double, :triple)
    #
    #   # exactly equivalent to
    #
    #   multiplier.unstub(:double)
    #   multiplier.unstub(:triple)
    def unstub(*method_names)
      mockery = Mocha::Mockery.instance
      method_names.each do |method_name|
        method = stubba_method.new(stubba_object, method_name)
        mockery.stubba.unstub(method)
      end
    end
  
    def method_exists?(method, include_public_methods = true) # :nodoc:
      if include_public_methods
        return true if public_methods(include_superclass_methods = true).include?(method)
        return true if respond_to?(method.to_sym)
      end
      return true if protected_methods(include_superclass_methods = true).include?(method)
      return true if private_methods(include_superclass_methods = true).include?(method)
      return false
    end
  
  end
  
  module ModuleMethods # :nodoc:
    
    def stubba_method
      Mocha::ModuleMethod
    end
    
  end
  
  # Methods added all classes to allow mocking and stubbing on real objects.
  module ClassMethods
    
    def stubba_method # :nodoc:
      Mocha::ClassMethod
    end

    class AnyInstance # :nodoc:
    
      def initialize(klass)
        @stubba_object = klass
      end
    
      def mocha
        @mocha ||= Mocha::Mockery.instance.mock_impersonating_any_instance_of(@stubba_object)
      end

      def stubba_method
        Mocha::AnyInstanceMethod
      end
    
      def stubba_object
        @stubba_object
      end

      def unstub(*method_names)
        mockery = Mocha::Mockery.instance
        method_names.collect! { |name| name.to_s }
        mockery.stubba.stubba_methods.select do |m|
          m.is_a?(Mocha::AnyInstanceMethod) && m.stubbee == self.stubba_object
        end.select { |m| method_names.include?(m.method.to_s) }.each { |s| s.unstub }
      end

      def method_exists?(method, include_public_methods = true)
        if include_public_methods
          return true if @stubba_object.public_instance_methods(include_superclass_methods = true).include?(method)
        end
        return true if @stubba_object.protected_instance_methods(include_superclass_methods = true).include?(method)
        return true if @stubba_object.private_instance_methods(include_superclass_methods = true).include?(method)
        return false
      end
    
    end
  
    # :call-seq: any_instance -> mock object
    #
    # Returns a mock object which will detect calls to any instance of this class.
    #   Product.any_instance.stubs(:save).returns(false)
    #   product_1 = Product.new
    #   assert_equal false, product_1.save
    #   product_2 = Product.new
    #   assert_equal false, product_2.save
    def any_instance
      @any_instance ||= AnyInstance.new(self)
    end
  
  end
  
end

class Object # :nodoc:
  include Mocha::ObjectMethods
end

class Module # :nodoc:
  include Mocha::ModuleMethods
end

class Class # :nodoc:
  include Mocha::ClassMethods
end
