class Resource < ApplicationRecord

  include HasCard

  belongs_to :player

end
