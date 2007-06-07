class License < ActiveRecord::Base
  belongs_to :customer
  belongs_to :product

  validates_numericality_of :customer_id, :product_id, :only_integer => true,
           :message => "must be an integer"
end
