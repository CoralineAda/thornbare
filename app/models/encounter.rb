class Encounter < ApplicationRecord

  include ::HasCard

  belongs_to :game

end
