class Customer < ActiveRecord::Base
  has_many :licenses
end
