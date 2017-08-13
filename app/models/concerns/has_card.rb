module HasCard

  extend ActiveSupport::Concern

  def card
    "#{self.class.name.downcase}_#{self.value}.png"
  end

end
