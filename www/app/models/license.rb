require "base32"
require "digest/sha2"
require "openssl"

class License < ActiveRecord::Base
  belongs_to :customer
  belongs_to :product

  validates_numericality_of :customer_id, :product_id, :only_integer => true,
           :message => "must be an integer"

  class << self
    def cipher
      @@cipher ||= OpenSSL::PKey::RSA.new(File.read('config/private.pem'))
    end

    def sign(string)
      cipher.private_encrypt(string)
    end
  end

  def digest
    Digest::SHA256.hexdigest(self.product.uuid + self.customer.fullname + self.created_at.to_s)
  end

  def key
    Base32.encode(self.class.sign(digest))
  end

  protected

  def validate
    errors.add(:customer, "invalid customer ID") if customer.nil?
    errors.add(:product, "invalid product ID") if product.nil?
  end
end
