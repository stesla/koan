class License < ActiveRecord::Base
  belongs_to :customer
  belongs_to :product
end
