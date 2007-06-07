module LicensingHelper
  def all_customers
    Customer.find_all.collect do |customer|
      [customer.fullname, customer.id.to_s]
    end
  end

  def all_products
    Product.find_all.collect do |product|
      [product.name, product.id.to_s]
    end
  end

  def wrap_text(text, width)
    return '' if text.nil?
    length = text.length
    chunks = length / width
    chunks -= 1 if length % width == 0
    (0..chunks).collect{|i| text[i * width, width]}.join("\n")
  end
end
