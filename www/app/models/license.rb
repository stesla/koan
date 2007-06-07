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

  def to_xml
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!(:xml, :version => "1.0")
    xml.declare!(:DOCTYPE, :plist,
                 :PUBLIC, "-//Apple Computer//DTD PLIST 1.0//EN",
                 "http://www.apple.com/DTDs/PropertyList-1.0.dtd")

    xml.plist(:version => "1.0") do
      xml.dict do
        xml.key "DateCreated"
        xml.string created_at.to_s(:long)
        xml.key "Key"
        xml.string key
        xml.key "Owner"
        xml.string customer.fullname
      end
    end
  end

  protected

  def validate
    errors.add(:customer, "invalid customer ID") if customer.nil?
    errors.add(:product, "invalid product ID") if product.nil?
  end
end
