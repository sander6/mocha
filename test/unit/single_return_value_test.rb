require File.expand_path('../../test_helper', __FILE__)

require 'mocha/single_return_value'

class SingleReturnValueTest < Test::Unit::TestCase
  
  include Mocha
  
  def test_should_return_value
    value = SingleReturnValue.new('value')
    assert_equal 'value', value.evaluate
  end
  
  def test_should_return_result_of_trivial_block
    value = SingleReturnValue.new { 'value' }
    assert_equal 'value', value.evaluate
  end
  
  def test_should_return_result_of_block_given_invocation_parameters
    value = SingleReturnValue.new { |a,b| a + b }
    assert_equal 2, value.evaluate(1,1)
  end
  
  def test_should_raise_ambiguous_return_error_if_given_block_and_non_nil_static_return_value
    assert_raises(Mocha::AmbiguousReturnError) { SingleReturnValue.new(2) { |a,b| a + b } }
  end
  
  def test_should_not_raise_ambiguous_return_error_if_given_block_and_nil_static_return_value
    assert_nothing_raised(Mocha::AmbiguousReturnError) { SingleReturnValue.new(nil) { |a,b| a + b } }
  end
  
end
