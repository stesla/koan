module LicensingHelper
  def wrap_text(text, width)
    return '' if text.nil?
    length = text.length
    chunks = length / width
    chunks -= 1 if length % width == 0
    (0..chunks).collect{|i| text[i * width, width]}.join("\n")
  end
end
