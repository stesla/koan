class LoadTestingData < ActiveRecord::Migration
  def self.up
    down

    customer = Customer.new(:first_name => "Testing",
                        :last_name => "User",
                        :email => "t.user@spambob.com")
    customer.save!

    koan = Product.new(:name => "Koan",
                       :uuid => "E463E475-DFB2-44D3-9A48-D30395AA0DFD")
    koan.save!

    license = License.new(:customer_id => customer.id, :product_id => koan.id)
    license.save!
  end

  def self.down
    License.delete_all
    Product.delete_all
    Customer.delete_all
  end
end
