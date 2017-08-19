class Resource < ApplicationRecord

  include HasCard

  belongs_to :player

  def self.lose(player, resource_values, total_resources_lost)
    sorted = resource_values.sort.reverse
    resources_to_remove = []
    resources_in_change = []
    sorted.each_with_index do |value, i|
      total_remaining = sorted[(i + 1)..-1].sum
      if value == total_resources_lost
        resources_to_remove << value
        break
      elsif value > total_resources_lost
        if total_remaining < total_resources_lost
          resources_to_remove << value
          resources_in_change << value - total_resources_lost
          break
        end
      elsif value < total_resources_lost
        if total_remaining < total_resources_lost
          resources_to_remove << value
        end
      end
    end
    {
      remove: resources_to_remove,
      change: resources_in_change
    }
  end

end
