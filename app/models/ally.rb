class Ally < ApplicationRecord

  include HasCard

  belongs_to :player

end
