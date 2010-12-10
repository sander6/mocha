require 'mocha/class_method'

module Mocha

  class AnyInstanceMethod < ClassMethod
  
    def initialize(stubbee, method)
      super
      @original_method = nil
      @original_method_visibility = :public
    end
  
    def unstub
      remove_new_method
      restore_original_method
      stubbee.any_instance.reset_mocha
    end
    
    def mock
      stubbee.any_instance.mocha
    end
   
    def hide_original_method
      if method_exists?(method)
        begin
          @original_method = stubbee.instance_method(method)
          @original_method_visibility = if stubbee.private_method_defined?(method)
            :private
          elsif stubbee.protected_method_defined?(method)
            :protected
          else
            :public
          end
          stubbee.send(:remove_method, method)
        rescue NameError
          @original_method = nil
        end
      end
    end

    def define_new_method
      stubbee.class_eval(%{
        def #{method}(*args, &block)
          self.class.any_instance.mocha.method_missing(:#{method}, *args, &block)
        end
      }, __FILE__, __LINE__)
    end

    def remove_new_method
      stubbee.send(:remove_method, method) rescue nil
    end

    def restore_original_method
      if @original_method
        stubbee.send :define_method, method, @original_method
        if @original_method_visibility != :public
          stubbee.send @original_method_visibility, method
        end
      end
    end

    def method_exists?(method)
      return true if stubbee.public_instance_methods(false).include?(method)
      return true if stubbee.protected_instance_methods(false).include?(method)
      return true if stubbee.private_instance_methods(false).include?(method)
      return false
    end
    
  end
  
end