require File.expand_path('../../test_helper', __FILE__)

require 'mocha/symbol_thrower'

class SymbolThrowerTest < Test::Unit::TestCase
  
  include Mocha

  def test_should_throw_symbol
    thrower = SymbolThrower.new(:symbol)
    assert_throws(:symbol) { thrower.evaluate }
  end
  
  def test_should_throw_object
    obj = Object.new
    thrower = SymbolThrower.new(:symbol, obj)
    thrown = catch(:symbol) { thrower.evaluate }    
    assert_equal obj, thrown
  end
  
  def test_should_return_nil_as_value_of_catch_block_if_not_given_object_to_throw
    thrower = SymbolThrower.new(:symbol)
    thrown = catch(:symbol) { thrower.evaluate }
    assert_nil thrown
  end

end