module HasCard

  def card
    "#{self.class.name.downcase}_#{self.value}.png"
  end

end
