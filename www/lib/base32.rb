class Base32
  class << self
    def encode(value)
      return '' if value.nil? or value.empty?
      buffer, result = value, ''
      while buffer && buffer.length > 0 do
        result << encode_chunk(buffer[0,5])
        buffer = buffer[5..-1]
      end
      result
    end

    def encode_bits(bits)
      %W(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 2 3 4 5 6 7)[bits]
    end

    def encode_chunk(chunk)
      result = ''
      padding = ((40 - chunk.size * 8) / 5)
      (8 - padding).times do |i|
        result += encode_chunk_at_position(chunk, i)
      end
      result + '=' * padding
    end

    def encode_chunk_at_position(chunk, position)
      buffer = chunk
      buffer += "\0" if (chunk.size * 8) / 5 == position
      bits = case position
             when 0: (buffer[0] & 0xF8) >> 3
             when 1: ((buffer[0] & 0x07) << 2) + ((buffer[1] & 0xC0) >> 6)
             when 2: ((buffer[1] & 0x3E) >> 1)
             when 3: ((buffer[1] & 0x01) << 4) + ((buffer[2] & 0xF0) >> 4)
             when 4: ((buffer[2] & 0x0F) << 1) + ((buffer[3] & 0x80) >> 7)
             when 5: ((buffer[3] & 0x7C) >> 2)
             when 6: ((buffer[3] & 0x03) << 3) + ((buffer[4] & 0xE0) >> 5)
             when 7: buffer[4] & 0x1F
             end
      encode_bits(bits)
    end
  end
end
