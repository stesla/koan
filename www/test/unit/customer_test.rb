require File.dirname(__FILE__) + '/../test_helper'

class CustomerTest < Test::Unit::TestCase
  fixtures :customers

  def test_fullname
    customer = Customer.new :first_name => 'Bob', :last_name => 'Jones'
    assert_equal('Bob Jones', customer.fullname)
  end
end
