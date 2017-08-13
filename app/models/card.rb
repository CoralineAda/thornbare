class Card

  attr_reader :name, :value

  def initialize(attrs={})
    @name = attrs[:name]
    @value = attrs[:value]
  end

  def card_image
    "#{self.name}_#{self.value}.png"
  end

end
