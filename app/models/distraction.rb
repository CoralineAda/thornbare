class Distraction < ApplicationRecord

  include HasCard

  belongs_to :player

end
