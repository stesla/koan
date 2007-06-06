class Base32
  class << self
    def encode(value)
      self.new(value).encode
    end
  end

  def initialize(value)
    @quintets = value.length * 8 / 5
    @remainder = value.length % 5
    @buffer = value + "\0" * @remainder
  end

  def encode
    (0..last_5_bit_position).collect{|i| encode_at_position(i)}.join + padding
  end

  private

  def encode_at_position(position)
    offset = position / 8 * 5
    bits = case position % 8
           when 0: (@buffer[offset + 0] & 0xF8) >> 3
           when 1: ((@buffer[offset + 0] & 0x07) << 2) + ((@buffer[offset + 1] & 0xC0) >> 6)
           when 2: ((@buffer[offset + 1] & 0x3E) >> 1)
           when 3: ((@buffer[offset + 1] & 0x01) << 4) + ((@buffer[offset + 2] & 0xF0) >> 4)
           when 4: ((@buffer[offset + 2] & 0x0F) << 1) + ((@buffer[offset + 3] & 0x80) >> 7)
           when 5: ((@buffer[offset + 3] & 0x7C) >> 2)
           when 6: ((@buffer[offset + 3] & 0x03) << 3) + ((@buffer[offset + 4] & 0xE0) >> 5)
           when 7: @buffer[offset + 4] & 0x1F
           else
             0
           end
    %W(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 2 3 4 5 6 7)[bits]
  end

  def last_5_bit_position
    @remainder == 0 ? @quintets - 1 : @quintets
  end

  def padding
    @remainder == 0 ? '' : '=' * ((5 - @remainder) * 8 / 5)
  end
end
