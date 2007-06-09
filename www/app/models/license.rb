require "base32"
require "digest/sha1"
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
    Digest::SHA1.hexdigest(product_code + owner + issued_date_string)
  end

  def issued_date_string
    created_at.to_s(:long)
  end

  def key
    Base32.encode(self.class.sign(digest))
  end

  def owner
    customer.fullname
  end

  def product_code
    product.uuid
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
        xml.string issued_date_string
        xml.key "Key"
        xml.string key
        xml.key "Owner"
        xml.string owner
      end
    end
  end

  protected

  def validate
    errors.add(:customer, "invalid customer ID") if customer.nil?
    errors.add(:product, "invalid product ID") if product.nil?
  end
end
