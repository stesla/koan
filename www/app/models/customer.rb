class Customer < ActiveRecord::Base
  has_many :licenses

  def fullname
    first_name + ' ' + last_name
  end
end
