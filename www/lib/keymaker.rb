require "active_support"
require "base32"
require "digest/sha1"
require "openssl"

module KeyMaker
  def private_key_path; end

  def cipher
    @@cipher ||= OpenSSL::PKey::RSA.new(File.read(private_key_path))
  end

  def sign(string)
    cipher.private_encrypt(string)
  end

  def identifier
    product_code + owner + issued_date_string
  end

  def digest
    Digest::SHA1.digest(identifier)
  end

  def hex_digest
    Digest::SHA1.hexdigest(identifier)
  end

  def issued_date_string
    created_at.to_s(:long)
  end

  def key
    Base32.encode(sign(digest))
  end

  def owner; end

  def product_code; end

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
end
