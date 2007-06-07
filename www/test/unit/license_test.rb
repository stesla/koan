require File.dirname(__FILE__) + '/../test_helper'

class LicenseTest < Test::Unit::TestCase
  fixtures :licenses

  def test_invalid_without_customer_or_product_id
    product = License.new
    assert !product.valid?
    assert product.errors.invalid?(:customer_id)
    assert product.errors.invalid?(:product_id)
  end

  def test_invalid_without_integer_customer_or_product_id
    product = License.new :product_id => 'foo', :customer_id => 1.0
    assert !product.valid?
    assert product.errors.invalid?(:customer_id)
    assert product.errors.invalid?(:product_id)
  end
end
